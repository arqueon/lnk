#!/bin/bash

# Directorio de aplicaciones
APP_DIR="$HOME/Applications"

# Buscar el AppImage más reciente que empiece por ExpanDrive
# El glob * ahora es más flexible para capturar espacios o versiones
APP_PATH=$(ls -t "$APP_DIR"/ExpanDrive*.appimage 2>/dev/null | head -n 1)

if [ -n "$APP_PATH" ] && [ -f "$APP_PATH" ]; then
    echo "Lanzando ExpanDrive desde: $APP_PATH"
    
    # 1. Matar procesos anteriores para evitar el error "already running"
    # Usamos || true para que el script no falle si no hay procesos
    pkill -f "ExpanDrive" || true
    sleep 1

    # 2. Entrar al directorio de la aplicación (ayuda con errores de rutas relativas)
    cd "$APP_DIR"

    # 3. Ejecutar la aplicación
    # Redirigimos la salida a /dev/null para que no ensucie los logs de niri
    "$APP_PATH" > /dev/null 2>&1 &
    
    # Desvincular el proceso para que siga vivo tras cerrar el script
    disown
else
    echo "Error: No se encontró ExpanDrive en $APP_DIR"
    exit 1
fi
