#!/usr/bin/env bash
# Lanzador de la ventana flotante de Fastfetch para Niri

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIEW_SCRIPT="$SCRIPT_DIR/fastfetch-view.sh"

if [[ ! -x "$VIEW_SCRIPT" ]]; then
    chmod +x "$VIEW_SCRIPT"
fi

exec kitty --class fastfetch-popup --app-id fastfetch-popup --title "System Fetch" "$VIEW_SCRIPT"
