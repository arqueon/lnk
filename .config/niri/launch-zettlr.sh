#!/bin/bash

# Enviar notificación para confirmar que el script se inicia
notify-send "Niri" "Iniciando Zettlr..." -i zettlr

# 1. Matar procesos anteriores (evitando suicidio del script)
pkill -x zettlr || pkill -f "/usr/lib/zettlr/app.asar" || true
sleep 1

# 2. Ejecutar con flags de Wayland
/usr/bin/zettlr --enable-features=UseOzonePlatform --ozone-platform=wayland > /dev/null 2>&1 &

disown
