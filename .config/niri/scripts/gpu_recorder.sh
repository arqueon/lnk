#!/bin/bash

# Configuración de rutas
VIDEO_DIR="$HOME/Videos"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="$VIDEO_DIR/recording_$TIMESTAMP.mp4"
PID_FILE="/tmp/gpu-screen-recorder.pid"

# Nombre del ejecutable para buscar (usaremos flag -f para buscar en todo el comando)
PROCESS_NAME="gpu-screen-recorder"

# Asegurarse de que el directorio existe
if [ ! -d "$VIDEO_DIR" ]; then
    mkdir -p "$VIDEO_DIR"
fi

# Comprobar si ya se está ejecutando usando -f (full command line)
if pgrep -f "$PROCESS_NAME" > /dev/null; then
    # --- DETENER GRABACIÓN ---
    # Usamos pkill -f para coincidir con el nombre largo y enviamos SIGINT
    # SIGINT es vital para que el video cierre bien (es como presionar Ctrl+C)
    pkill -SIGINT -f "$PROCESS_NAME"
    
    # Enviar notificación 
    notify-send "Grabación finalizada" "Guardado en: $(ls -t "$VIDEO_DIR" | head -n1)" -i video-x-generic
    
    rm -f "$PID_FILE"
else
    # --- INICIAR GRABACIÓN ---
    notify-send "Grabación iniciada" "Capturando pantalla..." -i camera-video
    
    # Ejecutar el comando
    nohup gpu-screen-recorder \
        -w portal \
        -f 60 \
        -k h264 \
        -ac opus \
        -a default_output \
        -q very_high \
        -cursor yes \
        -cr limited \
        -o "$FILENAME" > /dev/null 2>&1 &
        
    echo $! > "$PID_FILE"
fi