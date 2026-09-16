#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  launch-ai-menu.sh — Menú dinámico de herramientas de IA para Niri / DMS
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/niri/data"
LNK_DATA_DIR="$HOME/.config/lnk/.config/niri/data"

TSV_FILE="$DATA_DIR/ai-apps.tsv"
if [[ ! -f "$TSV_FILE" && -f "$LNK_DATA_DIR/ai-apps.tsv" ]]; then
    TSV_FILE="$LNK_DATA_DIR/ai-apps.tsv"
fi

if [[ ! -f "$TSV_FILE" ]]; then
    notify-send -u critical "AI Apps Menu" "No se encontró el catálogo de apps de IA en $TSV_FILE"
    exit 1
fi

PROMPT="󰚩 IA Apps ❯ "
PLACEHOLDER="Buscar servicio de IA (ej. claude, mindsmith, sora, mcp, flux, audio)..."

declare -A URL_MAP
MENU_ITEMS=""

while IFS=$'\t' read -r icon name url category desc; do
    [[ -z "$name" ]] && continue
    [[ "$icon" =~ ^# ]] && continue

    clean_display="$(printf "%s   %-22.22s │ %-14.14s │ %s" "$icon" "$name" "$category" "$desc")"
    URL_MAP["$clean_display"]="$url"
    if [[ -z "$MENU_ITEMS" ]]; then
        MENU_ITEMS="$clean_display"
    else
        MENU_ITEMS="$MENU_ITEMS"$'\n'"$clean_display"
    fi
done < "$TSV_FILE"

SELECTED=$(echo "$MENU_ITEMS" | fuzzel \
    --dmenu \
    --prompt="$PROMPT" \
    --placeholder="$PLACEHOLDER" \
    --width=80 \
    --lines=16 \
    --line-height=26 \
    --horizontal-pad=20 \
    --vertical-pad=12 \
    --match-mode=fzf 2>/dev/null || true)

if [[ -z "$SELECTED" ]]; then
    exit 0
fi

TARGET_URL="${URL_MAP[$SELECTED]:-}"

# Soporte si el usuario escribe una URL directa en el prompt
if [[ -z "$TARGET_URL" && "$SELECTED" =~ ^https?:// ]]; then
    TARGET_URL="$SELECTED"
fi

if [[ -n "$TARGET_URL" ]]; then
    if [[ -x "$SCRIPT_DIR/run_chrome.sh" ]]; then
        exec "$SCRIPT_DIR/run_chrome.sh" --app="$TARGET_URL"
    elif command -v google-chrome-beta >/dev/null 2>&1; then
        exec google-chrome-beta --no-default-browser-check --app="$TARGET_URL"
    elif command -v chromium >/dev/null 2>&1; then
        exec chromium --no-default-browser-check --app="$TARGET_URL"
    elif command -v xdg-open >/dev/null 2>&1; then
        exec xdg-open "$TARGET_URL"
    else
        notify-send "AI Apps Menu" "Abriendo: $TARGET_URL"
    fi
fi
