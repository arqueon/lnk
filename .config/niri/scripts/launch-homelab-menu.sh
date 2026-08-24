#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  launch-homelab-menu.sh — Menú dinámico de servicios para Niri / DMS
# ═══════════════════════════════════════════════════════════════════
# Uso: launch-homelab-menu.sh [sinope|nas-btb]

set -euo pipefail

TARGET="${1:-sinope}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/niri/data"
LNK_DATA_DIR="$HOME/.config/lnk/.config/niri/data"

# Determinar archivo TSV
TSV_FILE="$DATA_DIR/${TARGET}-services.tsv"
if [[ ! -f "$TSV_FILE" && -f "$LNK_DATA_DIR/${TARGET}-services.tsv" ]]; then
    TSV_FILE="$LNK_DATA_DIR/${TARGET}-services.tsv"
fi

# Si no existe, intentar sincronizar una vez
if [[ ! -f "$TSV_FILE" ]]; then
    if [[ -x "$SCRIPT_DIR/sync-homelab-services.py" ]]; then
        python3 "$SCRIPT_DIR/sync-homelab-services.py" >/dev/null 2>&1 || true
    fi
fi

if [[ ! -f "$TSV_FILE" ]]; then
    notify-send -u critical "Homelab Menu" "No se encontró el catálogo de servicios para $TARGET"
    exit 1
fi

# Configurar Prompt y Título
case "$TARGET" in
    sinope)
        PROMPT="󰒋 Sinope ❯ "
        PLACEHOLDER="Buscar servicio en Sinope (ej. digipad, nextcloud, jellyfin)..."
        ;;
    nas-btb|btb)
        PROMPT="󰒋 NAS-BTB ❯ "
        PLACEHOLDER="Buscar servicio en NAS Barbies Testeadoras..."
        ;;
    *)
        PROMPT="󰒋 $TARGET ❯ "
        PLACEHOLDER="Buscar servicio..."
        ;;
esac

# Generar lista formateada para fuzzel y mapa de URLs
declare -A URL_MAP
MENU_ITEMS=""

while IFS=$'\t' read -r display_name url category desc; do
    [[ -z "$display_name" ]] && continue
    # Formato: "󰽉 Digipad             [Docencia] Muros y pizarras colaborativas"
    # Usar printf para alineación consistente
    clean_display="$(printf "%-26.26s │ %-14.14s │ %s" "$display_name" "$category" "$desc")"
    URL_MAP["$clean_display"]="$url"
    if [[ -z "$MENU_ITEMS" ]]; then
        MENU_ITEMS="$clean_display"
    else
        MENU_ITEMS="$MENU_ITEMS"$'\n'"$clean_display"
    fi
done < "$TSV_FILE"

# Lanzar Fuzzel en modo dmenu
SELECTED=$(echo "$MENU_ITEMS" | fuzzel \
    --dmenu \
    --prompt="$PROMPT" \
    --placeholder="$PLACEHOLDER" \
    --width=70 \
    --lines=14 \
    --line-height=26 \
    --horizontal-pad=20 \
    --vertical-pad=12 \
    --match-mode=fzf 2>/dev/null || true)

if [[ -z "$SELECTED" ]]; then
    exit 0
fi

# Obtener URL del mapa
TARGET_URL="${URL_MAP[$SELECTED]:-}"

# Si el usuario escribió una URL manual
if [[ -z "$TARGET_URL" && "$SELECTED" =~ ^https?:// ]]; then
    TARGET_URL="$SELECTED"
fi

if [[ -n "$TARGET_URL" ]]; then
    # Lanzar como Chrome App Window independiente (o navegador del sistema)
    if [[ -x "$SCRIPT_DIR/run_chrome.sh" ]]; then
        exec "$SCRIPT_DIR/run_chrome.sh" --app="$TARGET_URL"
    elif command -v google-chrome-stable >/dev/null 2>&1; then
        exec google-chrome-stable --no-default-browser-check --app="$TARGET_URL"
    elif command -v xdg-open >/dev/null 2>&1; then
        exec xdg-open "$TARGET_URL"
    else
        notify-send "Homelab Menu" "Abriendo: $TARGET_URL"
    fi
fi
