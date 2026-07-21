#!/bin/bash

# 0. Lanzar aplicaciones multimedia adicionales (DroppedNeedle y Aonsoku)
~/.config/niri/scripts/run_chrome.sh --app="https://droppedneedle.arqueonautis.org/" &
sleep 0.2
/opt/Aonsoku/aonsoku &

# 1. Define el App ID que quieres buscar
APP_ID="cinhimbnkkaeohfgghhklpknlkffjgod"

# 2. Busca el archivo .desktop generado por Chrome en el directorio del usuario
DESKTOP_FILE=$(grep -l "app-id=$APP_ID" "$HOME"/.local/share/applications/*.desktop 2>/dev/null | head -n 1)

# 3. Si no lo encuentra ahí, busca en la carpeta Desktop/Escritorio
if [ -z "$DESKTOP_FILE" ]; then
    DESKTOP_FILE=$(grep -l "app-id=$APP_ID" "$HOME"/Desktop/*.desktop "$HOME"/Escritorio/*.desktop 2>/dev/null | head -n 1)
fi

# 4. Validar si se encontró el archivo y ejecutar el comando interno
if [ -n "$DESKTOP_FILE" ]; then
    # Extrae la línea que empieza con "Exec=", limpia el prefijo y ejecuta el comando
    EXEC_CMD=$(grep '^Exec=' "$DESKTOP_FILE" | tail -1 | sed 's/^Exec=//' | sed 's/%U//g')
    
    echo "Aplicación encontrada en: $DESKTOP_FILE"
    echo "Ejecutando: $EXEC_CMD"
    
    # Ejecuta en segundo plano y se desentiende de la terminal
    eval "$EXEC_CMD" & disown
else
    echo "Error: No se encontró ningún acceso directo para el APP-ID: $APP_ID"
    exit 1
fi
