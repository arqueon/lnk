#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  Hermes Agent Launcher (Niri WM / Chrome App)
# ═══════════════════════════════════════════════════════════════════
# Abre la interfaz del agente Hermes como una Chrome App independiente.
# Permite sobreescribir la URL pasando un argumento ($1).

set -euo pipefail

HERMES_URL="${1:-http://100.107.89.3:8787/session/35b6a51e059c}"

exec "$HOME/.config/niri/scripts/run_chrome.sh" --app="$HERMES_URL"
