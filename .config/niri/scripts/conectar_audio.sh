#!/bin/bash

POSEIDON_MAC="CC:BF:0C:04:22:34"
POSEIDON_NAME="Poseidon D80"

EARFUN_MAC="70:5A:6F:6B:6F:87"
EARFUN_NAME="EarFun Air Pro 4"

if [ "$1" == "poseidon" ]; then
    MAC=$POSEIDON_MAC
    NAME=$POSEIDON_NAME
elif [ "$1" == "earfun" ]; then
    MAC=$EARFUN_MAC
    NAME=$EARFUN_NAME
else
    echo "Uso: $0 [poseidon|earfun]"
    echo ""
    echo "Ejemplo: $0 poseidon"
    exit 1
fi
# Asegurar que el adaptador bluetooth esté encendido
bluetoothctl power on

# Desconectar primero para evitar estados inconsistentes
echo "Desconectando $NAME por si acaso..."
bluetoothctl disconnect $MAC >/dev/null 2>&1
sleep 1

echo "Intentando conectar a $NAME ($MAC)..."
MAX_RETRIES=3
CONNECTED=false

for ((i=1; i<=MAX_RETRIES; i++)); do
    echo "Intento de conexión $i de $MAX_RETRIES..."
    bluetoothctl connect $MAC
    sleep 2
    if bluetoothctl info $MAC | grep -q "Connected: yes"; then
        CONNECTED=true
        break
    fi
done

if [ "$CONNECTED" = false ]; then
    echo "Error: No se pudo conectar a $NAME ($MAC)."
    if command -v notify-send >/dev/null; then
        notify-send "Bluetooth" "Error al conectar a $NAME" -u critical
    fi
    exit 1
fi

echo "Conectado por Bluetooth. Esperando a que PipeWire reconozca el dispositivo..."
SINK_ID=""
for ((i=1; i<=10; i++)); do
    # Extraemos el primer número de ID seguido de un punto, evitando decimales de volumen
    SINK_ID=$(wpctl status | awk '/Sinks:/,/Sources:/' | grep -i "$NAME" | grep -o -E '[0-9]+\.' | head -n 1 | tr -d '.')
    if [ -n "$SINK_ID" ]; then
        break
    fi
    sleep 1
done

if [ -n "$SINK_ID" ]; then
    echo "Estableciendo $NAME (ID: $SINK_ID) como salida de audio predeterminada..."
    wpctl set-default $SINK_ID
    
    # Desmutar y asegurar un volumen inicial razonable (50%)
    wpctl set-mute $SINK_ID 0
    wpctl set-volume $SINK_ID 0.5
    
    echo "¡Listo! El audio ahora debería sonar por $NAME."
    if command -v notify-send >/dev/null; then
        notify-send "Audio" "$NAME conectado y configurado como salida predeterminada" -i audio-speakers
    fi
else
    echo "Advertencia: No se encontró el dispositivo en las salidas de audio de PipeWire."
    if command -v notify-send >/dev/null; then
        notify-send "Audio" "$NAME se conectó pero PipeWire no lo reconoce" -u normal
    fi
fi
