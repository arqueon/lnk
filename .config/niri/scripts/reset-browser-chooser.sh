#!/usr/bin/env bash
# Restablece DMS Chooser como manejador predeterminado para enlaces HTTP/HTTPS y archivos HTML
xdg-mime default dms-open.desktop x-scheme-handler/http x-scheme-handler/https text/html application/xhtml+xml
xdg-settings set default-web-browser dms-open.desktop
dms ipc call toast info "Selector web restablecido a DMS Chooser" >/dev/null 2>&1 || notify-send -a "DMS" "Selector restablecido" "DMS Chooser activo para enlaces y HTML"
