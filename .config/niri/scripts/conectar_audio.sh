#!/usr/bin/env bash
set -euo pipefail

POSEIDON_MAC="CC:BF:0C:04:22:34"
POSEIDON_NAME="Poseidon D80"
POSEIDON_VOL="45%"

EARFUN_MAC="70:5A:6F:6B:6F:87"
EARFUN_NAME="EarFun Air Pro 4"
EARFUN_VOL="35%"

LOCAL_SINK="alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink"
LOCAL_NAME="Bocinas locales"
LOCAL_VOL="40%"

TARGET="${1:-}"

MAX_BT_RETRIES=3
BT_RETRY_DELAY=3
BT_CONNECT_TIMEOUT=12

notify() {
    local title=$1
    local body=$2
    local urgency=${3:-normal}
    local icon=${4:-audio-speakers}

    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$body" -u "$urgency" -i "$icon"
    fi
}

move_streams_to_sink() {
    local sink=$1
    local inputs
    inputs=$(pactl list sink-inputs short 2>/dev/null | awk '{print $1}')
    for id in $inputs; do
        pactl move-sink-input "$id" "$sink" >/dev/null 2>&1 || true
    done
}

cleanup_parasitic_clock() {
    # Evita que whisperer-aec o módulos de cancelación de eco colapsen el reloj Bluetooth
    if pgrep -f "whisperer-aec-holder" >/dev/null 2>&1 || pw-link -l 2>/dev/null | grep -q "echo-cancel-sink"; then
        pkill -9 -f "whisperer-aec-holder" >/dev/null 2>&1 || true
        pkill -9 -f "pw-cli <&8" >/dev/null 2>&1 || true
        sleep 0.5
    fi
}

find_sink() {
    local bt_id=$1
    pactl list sinks short 2>/dev/null |
        awk -v bt_id="$bt_id" '$2 ~ ("^bluez_output\\." bt_id) { print $2; exit }'
}

find_card() {
    local card_name=$1
    pactl list cards short 2>/dev/null |
        awk -v card="$card_name" '$2 == card { print $2; exit }'
}

wait_for_sink() {
    local bt_id=$1
    local seconds=${2:-12}
    local sink=""

    for ((i = 1; i <= seconds; i++)); do
        sink=$(find_sink "$bt_id")
        if [ -n "$sink" ]; then
            printf '%s\n' "$sink"
            return 0
        fi
        sleep 1
    done

    return 1
}

wait_for_card() {
    local card_name=$1
    local seconds=${2:-6}

    for ((i = 1; i <= seconds; i++)); do
        if [ -n "$(find_card "$card_name")" ]; then
            return 0
        fi
        sleep 1
    done

    return 1
}

ensure_bluetooth_ready() {
    # Nunca hacer «rfkill block»: si el adaptador se reinicia a la vez (el RTL8761BU lo hace al colgarse),
    # systemd-rfkill guarda el bloqueo y el adaptador vuelve bloqueado. Solo desbloquear. (2026-10-24)
    rfkill unblock bluetooth >/dev/null 2>&1 || true
    for ((i = 1; i <= 5; i++)); do
        bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && return 0
        echo "Asegurando Bluetooth activo ($i/5)..."
        bluetoothctl power on >/dev/null 2>&1 || true
        sleep 1
    done
    # Sigue sin encender: el firmware del adaptador está colgado (kernel: «tx timeout» / «-110»).
    echo "Error: el adaptador Bluetooth no responde. Reconéctalo o ejecuta: sudo usbreset 0bda:a728"
    notify "Bluetooth colgado" "El adaptador no responde. Desconecta y reconecta el USB Bluetooth (o: sudo usbreset 0bda:a728)." critical dialog-error
    exit 1
}

apply_sink_config() {
    local sink=$1
    local name=$2
    local target_vol=$3

    echo "Configurando $name ($sink) como salida activa..."
    pactl set-default-sink "$sink"
    pactl set-sink-mute "$sink" 0
    pactl set-sink-volume "$sink" "$target_vol"
    move_streams_to_sink "$sink"

    notify "$name" "Conectado y listo (Volumen: $target_vol)"
    echo "Listo. Audio reproduciéndose en $name."
}

# ── Modo salida local / bocinas de escritorio ──
if [ "$TARGET" = "local" ] || [ "$TARGET" = "bocinas" ]; then
    cleanup_parasitic_clock
    if ! pactl list sinks short 2>/dev/null | grep -q "$LOCAL_SINK"; then
        echo "Error: no se encontró el sink local $LOCAL_SINK"
        notify "Audio" "No se encontraron las bocinas locales" critical dialog-error
        exit 1
    fi
    apply_sink_config "$LOCAL_SINK" "$LOCAL_NAME" "$LOCAL_VOL"
    exit 0
fi

# ── Modos Bluetooth (Poseidon / EarFun) ──
if [ "$TARGET" = "poseidon" ]; then
    MAC=$POSEIDON_MAC
    NAME=$POSEIDON_NAME
    TARGET_VOL=$POSEIDON_VOL
elif [ "$TARGET" = "earfun" ]; then
    MAC=$EARFUN_MAC
    NAME=$EARFUN_NAME
    TARGET_VOL=$EARFUN_VOL
else
    echo "Uso: $0 [poseidon|earfun|local]"
    echo ""
    echo "Ejemplos:"
    echo "  $0 poseidon   # Conectar a barra Ultimea Poseidon D80"
    echo "  $0 earfun     # Conectar a audífonos EarFun Air Pro 4"
    echo "  $0 local      # Cambiar a bocinas locales de escritorio"
    exit 1
fi

BT_ID="${MAC//:/_}"
CARD_NAME="bluez_card.$BT_ID"

# 1. FAST PATH: ¿Ya está disponible el sink de audio?
EXISTING_SINK=$(find_sink "$BT_ID")
if [ -n "$EXISTING_SINK" ]; then
    echo "$NAME ya tiene sink activo ($EXISTING_SINK). Enrutando audio..."
    cleanup_parasitic_clock
    apply_sink_config "$EXISTING_SINK" "$NAME" "$TARGET_VOL"
    exit 0
fi

# 2. Si no está el sink, verificar y preparar conexión Bluetooth
cleanup_parasitic_clock
ensure_bluetooth_ready

# Primera vez en este equipo (p. ej. abdel-home): emparejar. El dispositivo debe estar en modo de emparejamiento.
if ! bluetoothctl info "$MAC" 2>/dev/null | grep -q "Paired: yes"; then
    echo "$NAME no está emparejado en este equipo; buscándolo (ponlo en modo de emparejamiento)..."
    notify "$NAME" "Emparejando por primera vez: pon el dispositivo en modo de emparejamiento." normal bluetooth
    timeout 25 bluetoothctl --timeout 20 scan on >/dev/null 2>&1 &
    SCAN_PID=$!
    for ((i = 1; i <= 20; i++)); do
        bluetoothctl devices 2>/dev/null | grep -qi "$MAC" && break
        sleep 1
    done
    if ! timeout 25 bluetoothctl pair "$MAC" >/dev/null 2>&1; then
        kill "$SCAN_PID" >/dev/null 2>&1 || true
        bluetoothctl scan off >/dev/null 2>&1 || true
        echo "Error: no se pudo emparejar $NAME."
        notify "$NAME" "No se pudo emparejar. ¿Está en modo de emparejamiento y cerca?" critical dialog-error
        exit 1
    fi
    kill "$SCAN_PID" >/dev/null 2>&1 || true
    bluetoothctl scan off >/dev/null 2>&1 || true
    echo "$NAME emparejado."
fi

bluetoothctl trust "$MAC" >/dev/null 2>&1 || true

# Si está en estado fantasma (Connected: yes pero sin audio), forzar desconexión limpia primero
if bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"; then
    echo "Desconectando sesión previa incompleta de $NAME..."
    bluetoothctl disconnect "$MAC" >/dev/null 2>&1 || true
    sleep 2
fi

CONNECTED=false
SINK_NAME=""

for ((attempt = 1; attempt <= MAX_BT_RETRIES; attempt++)); do
    echo "Intento de conexión $attempt de $MAX_BT_RETRIES a $NAME ($MAC)..."
    ensure_bluetooth_ready
    
    # Intentar conexión directa
    if timeout "$BT_CONNECT_TIMEOUT" bluetoothctl connect "$MAC" >/dev/null 2>&1; then
        # Esperar a que PipeWire cree la tarjeta o sink
        if wait_for_card "$CARD_NAME" 6; then
            pactl set-card-profile "$CARD_NAME" "a2dp-sink" >/dev/null 2>&1 || true
        fi
        
        SINK_NAME=$(wait_for_sink "$BT_ID" 8 || true)
        if [ -n "$SINK_NAME" ]; then
            CONNECTED=true
            break
        fi
    fi

    echo "Reintento necesario; esperando ${BT_RETRY_DELAY}s para que el dispositivo libere el bus..."
    bluetoothctl disconnect "$MAC" >/dev/null 2>&1 || true
    sleep "$BT_RETRY_DELAY"
done

if [ "$CONNECTED" = false ] || [ -z "${SINK_NAME:-}" ]; then
    echo "Error: No se pudo establecer la salida de audio para $NAME."
    echo "Verifica que el dispositivo esté encendido, en modo Bluetooth y no esté conectado a otro teléfono/equipo."
    notify "$NAME" "No se pudo conectar. Verifica que esté en modo BT y encendido." critical dialog-error
    exit 1
fi

cleanup_parasitic_clock
apply_sink_config "$SINK_NAME" "$NAME" "$TARGET_VOL"
