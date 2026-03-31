#!/bin/bash

# Directorio de aplicaciones
APP_DIR="$HOME/Applications"

# Buscar el ejecutable de Anytype más reciente
# El glob anytype_* captura el nombre específico encontrado
APP_PATH=$(ls -t "$APP_DIR"/anytype_* 2>/dev/null | head -n 1)

if [ -n "$APP_PATH" ] && [ -f "$APP_PATH" ]; then
    echo "Lanzando Anytype desde: $APP_PATH"
    
    # 1. Matar procesos anteriores para evitar conflictos
    pkill -f "anytype" || true
    sleep 1

    # 2. Entrar al directorio de la aplicación
    cd "$APP_DIR"

    # 3. Ejecutar la aplicación
    # Redirigimos la salida a /dev/null para que no ensucie los logs
    "$APP_PATH" > /dev/null 2>&1 &
    
    # Desvincular el proceso para que siga vivo tras cerrar el script
    disown
else
    echo "Error: No se encontró Anytype en $APP_DIR"
    exit 1
fi
