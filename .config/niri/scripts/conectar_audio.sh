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

echo "Intentando conectar a $NAME ($MAC)..."
bluetoothctl connect $MAC

echo "Esperando 4 segundos a que PipeWire reconozca el dispositivo de audio..."
sleep 4

# Buscamos el ID del dispositivo en la lista de salidas de audio (Sinks)
SINK_ID=$(wpctl status | awk '/Sinks:/,/Sources:/' | grep -i "$NAME" | head -n 1 | grep -o '[0-9]*\.' | tr -d '.')

if [ -n "$SINK_ID" ]; then
    echo "Estableciendo $NAME (ID: $SINK_ID) como salida de audio predeterminada..."
    wpctl set-default $SINK_ID
    echo "¡Listo! El audio ahora debería sonar por ahí."
else
    echo "Advertencia: No se encontró el dispositivo en las salidas de audio."
    echo "Es posible que no se haya conectado correctamente o que siga apagado."
fi
