#!/usr/bin/env bash

POSEIDON_MAC="CC:BF:0C:04:22:34"
POSEIDON_NAME="Poseidon D80"

EARFUN_MAC="70:5A:6F:6B:6F:87"
EARFUN_NAME="EarFun Air Pro 4"

if [ "${1:-}" = "poseidon" ]; then
    MAC=$POSEIDON_MAC
    NAME=$POSEIDON_NAME
elif [ "${1:-}" = "earfun" ]; then
    MAC=$EARFUN_MAC
    NAME=$EARFUN_NAME
else
    echo "Uso: $0 [poseidon|earfun]"
    echo ""
    echo "Ejemplo: $0 poseidon"
    exit 1
fi

BT_ID="${MAC//:/_}"
CARD_NAME="bluez_card.$BT_ID"
MAX_BT_RETRIES=4
BT_RETRY_DELAY=3
BT_CONNECT_TIMEOUT=15
PIPEWIRE_WAIT_SECONDS=30

notify() {
    local title=$1
    local body=$2
    local urgency=${3:-normal}
    local icon=${4:-audio-speakers}

    if command -v notify-send >/dev/null; then
        notify-send "$title" "$body" -u "$urgency" -i "$icon"
    fi
}

require_command() {
    if ! command -v "$1" >/dev/null; then
        echo "Error: falta el comando requerido: $1"
        notify "Audio Bluetooth" "Falta el comando requerido: $1" critical dialog-error
        exit 1
    fi
}

bt_connected() {
    echo -e "select 8C:68:8B:40:F7:53\ninfo $MAC" | bluetoothctl 2>/dev/null | grep -q "Connected: yes"
}

connect_bt() {
    echo -e "select 8C:68:8B:40:F7:53\nconnect $MAC" | timeout "$BT_CONNECT_TIMEOUT" bluetoothctl
}

disconnect_bt() {
    echo -e "select 8C:68:8B:40:F7:53\ndisconnect $MAC" | bluetoothctl >/dev/null 2>&1
}


find_sink() {
    pactl list sinks short 2>/dev/null |
        awk -v bt_id="$BT_ID" '$2 ~ ("^bluez_output\\." bt_id) { print $2; exit }'
}

find_card() {
    pactl list cards short 2>/dev/null |
        awk -v card="$CARD_NAME" '$2 == card { print $2; exit }'
}

wait_for_sink() {
    local seconds=${1:-$PIPEWIRE_WAIT_SECONDS}
    local sink=""

    for ((i = 1; i <= seconds; i++)); do
        sink=$(find_sink)
        if [ -n "$sink" ]; then
            printf '%s\n' "$sink"
            return 0
        fi
        sleep 1
    done

    return 1
}

wait_for_card() {
    local seconds=${1:-10}

    for ((i = 1; i <= seconds; i++)); do
        if [ -n "$(find_card)" ]; then
            return 0
        fi
        sleep 1
    done

    return 1
}

prefer_a2dp_profile() {
    local card
    card=$(find_card)

    if [ -z "$card" ]; then
        return 1
    fi

    # PipeWire/WirePlumber exposes different A2DP profile names depending on codecs.
    local profiles=(
        "a2dp-sink"
        "a2dp-sink-sbc_xq"
        "a2dp-sink-sbc"
        "a2dp-sink-aac"
        "a2dp-sink-ldac"
    )

    for profile in "${profiles[@]}"; do
        if pactl set-card-profile "$card" "$profile" >/dev/null 2>&1; then
            echo "Perfil de audio activo: $profile"
            return 0
        fi
    done

    return 1
}

restart_audio_stack() {
    echo "Reiniciando WirePlumber y pipewire-pulse para forzar nueva enumeración..."
    systemctl --user restart wireplumber pipewire-pulse >/dev/null 2>&1
    sleep 3
}

reconnect_bt() {
    echo "Forzando nuevo evento Bluetooth para $NAME..."

    for ((i = 1; i <= MAX_BT_RETRIES; i++)); do
        echo "Reintento de reconexión $i de $MAX_BT_RETRIES..."
        disconnect_bt
        sleep 2
        connect_bt
        sleep "$BT_RETRY_DELAY"

        if bt_connected; then
            return 0
        fi
    done

    return 1
}

configure_sink() {
    local sink=$1

    echo "Estableciendo $NAME como salida predeterminada ($sink)..."
    pactl set-default-sink "$sink" &&
        pactl set-sink-mute "$sink" 0 &&
        pactl set-sink-volume "$sink" 50%
}

require_command bluetoothctl
require_command pactl
require_command systemctl
require_command timeout

echo "Encendiendo Bluetooth, apagando escaneo y confiando en $NAME..."
echo -e "select 8C:68:8B:40:F7:53\npower on\nscan off\nagent on\ndefault-agent\ntrust $MAC" | bluetoothctl >/dev/null 2>&1

echo "Intentando conectar a $NAME ($MAC)..."
CONNECTED=false

for ((i = 1; i <= MAX_BT_RETRIES; i++)); do
    echo "Intento de conexión $i de $MAX_BT_RETRIES..."
    disconnect_bt
    sleep 2
    connect_bt
    sleep "$BT_RETRY_DELAY"

    if bt_connected; then
        CONNECTED=true
        break
    fi
done

if [ "$CONNECTED" = false ]; then
    echo "Error: No se pudo conectar a $NAME ($MAC)."
    notify "Bluetooth" "Error al conectar a $NAME" critical dialog-error
    exit 1
fi

echo "Conectado por Bluetooth. Esperando sink de PipeWire/PulseAudio..."
SINK_NAME=$(wait_for_sink 12)

if [ -z "$SINK_NAME" ]; then
    echo "No apareció sink todavía; buscando card $CARD_NAME y forzando perfil A2DP..."
    if wait_for_card 8; then
        prefer_a2dp_profile
        SINK_NAME=$(wait_for_sink 12)
    fi
fi

if [ -z "$SINK_NAME" ]; then
    restart_audio_stack

    if ! reconnect_bt; then
        echo "Error: $NAME no respondió al reconectar Bluetooth después de reiniciar PipeWire."
        notify "Bluetooth" "$NAME no respondió al reconectar" critical dialog-error
        exit 1
    fi

    if wait_for_card 10; then
        prefer_a2dp_profile
    fi

    SINK_NAME=$(wait_for_sink "$PIPEWIRE_WAIT_SECONDS")
fi

if [ -z "$SINK_NAME" ]; then
    if bt_connected; then
        echo "Advertencia: $NAME está conectado por Bluetooth, pero PipeWire no creó un sink $BT_ID."
    else
        echo "Advertencia: $NAME no quedó conectado por Bluetooth y PipeWire no creó un sink $BT_ID."
    fi
    echo "Diagnóstico sugerido:"
    echo "  pactl list cards short | grep $BT_ID"
    echo "  pactl list sinks short | grep $BT_ID"
    echo "  journalctl --user -u wireplumber -u pipewire-pulse -n 80 --no-pager"
    notify "Audio" "$NAME conectado, pero PipeWire no creó salida de audio" normal dialog-warning
    exit 2
fi

if ! configure_sink "$SINK_NAME"; then
    echo "Error: PipeWire encontró $SINK_NAME, pero no pude configurarlo como salida."
    notify "Audio" "$NAME conectado, pero no se pudo configurar la salida" critical dialog-error
    exit 3
fi

echo "Listo. El audio ahora debería sonar por $NAME."
notify "Audio" "$NAME conectado y configurado como salida predeterminada"
