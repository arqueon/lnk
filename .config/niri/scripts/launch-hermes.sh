#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  Hermes Agent Launcher (Niri WM / Chrome App)
# ═══════════════════════════════════════════════════════════════════
# Abre la interfaz del agente Hermes como una Chrome App independiente.
# Permite sobreescribir la URL pasando un argumento ($1) o mediante
# detección automática del host/usuario.

set -euo pipefail

host_name="$(hostnamectl --static 2>/dev/null || hostname 2>/dev/null || echo "")"
current_user="${USER:-$(id -un 2>/dev/null || echo "")}"

if [ -n "${1:-}" ]; then
    HERMES_URL="$1"
elif [[ "$host_name" =~ ^abdel ]] || [ "$current_user" = "abdel" ]; then
    HERMES_URL="http://192.168.100.12:8788/"
else
    HERMES_URL="http://100.107.89.3:8787/session/35b6a51e059c"
fi

exec "$HOME/.config/niri/scripts/run_chrome.sh" --app="$HERMES_URL"

