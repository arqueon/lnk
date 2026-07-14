#!/bin/bash

# Abre las WebUI de gestión multimedia como ventanas Chrome App independientes.
# Se lanzan con una pausa corta para que una primera instancia de Chrome pueda
# adquirir el perfil antes de que las siguientes se conecten a ella.
urls=(
    "https://droppedneedle.arqueonautis.org/"
    "https://aurral.arqueonautis.org"
    "https://sabnzbd.arqueonautis.org"
    "https://lidarr.arqueonautis.org"
    "http://localhost:8080"
    "https://qbittorrent.arqueonautis.org"
    "https://sinope.tailf70cf8.ts.net:5031/downloads"
)

for url in "${urls[@]}"; do
    ~/.config/niri/scripts/run_chrome.sh --app="$url" &
    sleep 0.2
done

# Aonsoku ya es una aplicación nativa; su binario no está en PATH.
/opt/Aonsoku/aonsoku &
