#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  launch-ferdium-menu.sh — Menú Fuzzel para conmutar modo de Ferdium
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

PROMPT="󰒱 Ferdium ❯ "
PLACEHOLDER="Seleccionar modo (nube, local, reiniciar, estado)..."

# Obtener estado actual
STATUS_INFO="$($HOME/.local/bin/ferdium-modo status 2>/dev/null || true)"
CURRENT_MODE="desconocido"
if echo "$STATUS_INFO" | grep -q "Modo configurado: local"; then
    CURRENT_MODE="local"
elif echo "$STATUS_INFO" | grep -q "Modo configurado: cloud"; then
    CURRENT_MODE="nube"
fi

if echo "$STATUS_INFO" | grep -q "ONLINE"; then
    SERVER_STATUS="ONLINE"
else
    SERVER_STATUS="OFFLINE"
fi

OPT_CLOUD="󰖟   Modo Nube (NAS-BTB)        │ ferdium.arqueonautis.org │ Sincronizado vía Cloudflare"
OPT_LOCAL="󰒋   Modo Local Autónomo        │ 100% Offline             │ Sin servidor / server.sqlite"
OPT_RESTART="󰑐   Reiniciar Ferdium          │ Proceso activo           │ Reinicia la app en modo actual"
OPT_STATUS="󰄬   Ver Estado / Diagnóstico   │ Modo: $CURRENT_MODE | NAS: $SERVER_STATUS │ Notificación en pantalla"

if [ "$CURRENT_MODE" = "nube" ]; then
    OPT_CLOUD="󰖟   [ACTIVO] Modo Nube         │ ferdium.arqueonautis.org │ Sincronizado vía Cloudflare"
elif [ "$CURRENT_MODE" = "local" ]; then
    OPT_LOCAL="󰒋   [ACTIVO] Modo Local        │ 100% Offline             │ Sin servidor / server.sqlite"
fi

MENU_ITEMS="${OPT_CLOUD}
${OPT_LOCAL}
${OPT_RESTART}
${OPT_STATUS}"

SELECTED=$(echo "$MENU_ITEMS" | fuzzel \
    --dmenu \
    --prompt="$PROMPT" \
    --placeholder="$PLACEHOLDER" \
    --width=95 \
    --lines=4 \
    --line-height=28 \
    --horizontal-pad=20 \
    --vertical-pad=12 \
    --match-mode=fzf 2>/dev/null || true)

if [[ -z "$SELECTED" ]]; then
    exit 0
fi

case "$SELECTED" in
    *"Modo Nube"*)
        $HOME/.local/bin/ferdium-modo cloud -r
        notify-send -i ferdium "Ferdium" "Modo Nube activado (nas-btb vía Cloudflare Tunnel)"
        ;;
    *"Modo Local"*)
        $HOME/.local/bin/ferdium-modo local -r
        notify-send -i ferdium "Ferdium" "Modo Local activado (100% offline / server.sqlite)"
        ;;
    *"Reiniciar Ferdium"*)
        $HOME/.local/bin/ferdium-modo restart
        notify-send -i ferdium "Ferdium" "Ferdium reiniciado correctamente"
        ;;
    *"Ver Estado"*)
        RES="$($HOME/.local/bin/ferdium-modo status)"
        notify-send -i ferdium -t 6000 "Ferdium Estado" "$RES"
        ;;
esac
