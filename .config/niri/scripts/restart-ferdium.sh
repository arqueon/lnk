#!/bin/bash
# Forzar el PATH para que Niri encuentre pgrep, kill y ferdium
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/ruben/.bin

# Log para ver qué pasa
exec > /tmp/restart-ferdium.log 2>&1
echo "--- Reiniciando Ferdium a las $(date) ---"

# 1. Matar Ferdium
PIDS=$(pgrep -f "/opt/ferdium-bin/" | grep -v $$)
if [ -n "$PIDS" ]; then
    echo "PIDs encontrados: $PIDS. Matando..."
    kill $PIDS
    sleep 2
    # Forzar si sigue vivo
    pgrep -f "/opt/ferdium-bin/" | xargs -r kill -9
else
    echo "No se encontraron procesos de Ferdium activos."
fi

# 2. Variables críticas para Wayland
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export XDG_SESSION_TYPE=wayland
export XDG_RUNTIME_DIR=/run/user/$(id -u)

# 3. Lanzar usando 'setsid' para que el proceso sea totalmente independiente de Niri
echo "Lanzando Ferdium..."
setsid /usr/bin/ferdium > /dev/null 2>&1 &

echo "Script finalizado con éxito."
exit 0
