#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  launch-homelab-menu.sh — Menú único de servicios para Niri / DMS
# ═══════════════════════════════════════════════════════════════════
# Uso: launch-homelab-menu.sh [sinope|nas-btb]
#   Sin argumento abre el primer nivel: categorías, «Hosts ▸» y «Buscar en todo».
#   Con un host abre directo su lista (compatibilidad con atajos anteriores).
# Catálogo: data/homelab-catalog.tsv, generado por sync-homelab-services.py
#   (icono, nombre, url, categoría, host, estado, descripción).
# 2026-10-24: unifica Mod+Ctrl+S (Sinope) y Mod+Ctrl+B (NAS-BTB) en un solo menú;
# el host sale de dónde corre el servicio, no del dominio.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/niri/data"
LNK_DATA_DIR="$HOME/.config/lnk/.config/niri/data"

CATALOG="$DATA_DIR/homelab-catalog.tsv"
[[ -f "$CATALOG" ]] || CATALOG="$LNK_DATA_DIR/homelab-catalog.tsv"
if [[ ! -f "$CATALOG" && -x "$SCRIPT_DIR/sync-homelab-services.py" ]]; then
    python3 "$SCRIPT_DIR/sync-homelab-services.py" >/dev/null 2>&1 || true
fi
if [[ ! -f "$CATALOG" ]]; then
    notify-send -u critical "Servicios" "No se encontró el catálogo homelab-catalog.tsv"
    exit 1
fi

# Orden e iconos del primer nivel (las mismas categorías que escribe el sync)
CATEGORIES=("Media|󰎈" "Descargas y *arr|󰇚" "Educación|󰑴" "Productividad|󰏫"
            "Agentes e IA|󰚩" "Hogar y finanzas|󰋜" "Sitios públicos|󰖟" "Administración|󰒓")
HOST_LABEL_sinope="Sinope"
HOST_LABEL_nas_btb="NAS-BTB"
BACK="‹  Volver"
# Página generada en sinope con todos los equipos de la tailnet y sus servicios (~/Projects/utils/tailnet-inicio)
TAILNET="󰖟   Tailnet · equipos y servicios"
TAILNET_URL="https://sinope.tailf70cf8.ts.net:8600/"

host_label() { local v="HOST_LABEL_${1//-/_}"; printf '%s' "${!v:-$1}"; }

# fuzzel en modo dmenu; $1 prompt, $2 placeholder, stdin las líneas
pick() {
    local lines
    lines="$(cat)"
    printf '%s\n' "$lines" | fuzzel --dmenu --prompt="$1" --placeholder="$2" \
        --width=120 --lines="$(printf '%s\n' "$lines" | wc -l | awk '{print ($1 > 16 ? 16 : $1)}')" \
        --line-height=26 --horizontal-pad=20 --vertical-pad=12 \
        --match-mode=fzf 2>/dev/null || true
}

declare -A URL_MAP STATUS_MAP

# Lista de servicios filtrada; $1 columna (4 categoría, 5 host, 0 todos), $2 valor, $3 columna extra a mostrar
service_lines() {
    local col="$1" val="$2" extra="$3"
    local icon name url category host status desc shown mark
    while IFS=$'\t' read -r icon name url category host status desc; do
        [[ -z "$name" || "$icon" == \#* ]] && continue
        case "$col" in
            4) [[ "$category" == "$val" ]] || continue ;;
            5) [[ "$host" == "$val" ]] || continue ;;
        esac
        case "$extra" in
            host) shown="$(host_label "$host")" ;;
            category) shown="$category" ;;
            both) shown="$category · $(host_label "$host")" ;;
        esac
        mark=""
        [[ "$status" == "suspendido" ]] && mark="⏸ "
        local line
        line="$(printf "%s   %-28.28s │ %-26.26s │ %s" "$icon" "$mark$name" "$shown" "$desc")"
        URL_MAP["$line"]="$url"
        STATUS_MAP["$line"]="$status"
        printf '%s\n' "$line"
    done < "$CATALOG"
}

count_where() {  # $1 columna, $2 valor
    awk -F'\t' -v c="$1" -v v="$2" '!/^#/ && $c == v {n++} END {print n + 0}' "$CATALOG"
}

open_url() {
    local url="$1" status="$2"
    if [[ "$status" == "suspendido" ]]; then
        notify-send "Servicios" "Este servicio está suspendido; puede no responder."
    fi
    if [[ -x "$SCRIPT_DIR/run_chrome.sh" ]]; then
        exec "$SCRIPT_DIR/run_chrome.sh" --app="$url"
    elif command -v google-chrome-stable >/dev/null 2>&1; then
        exec google-chrome-stable --no-default-browser-check --app="$url"
    else
        exec xdg-open "$url"
    fi
}

# Muestra una lista de servicios y abre el elegido; devuelve 1 si se pidió volver
service_menu() {
    local prompt="$1" col="$2" val="$3" extra="$4" sel
    sel="$({ printf '%s\n' "$BACK"; service_lines "$col" "$val" "$extra"; } | pick "$prompt" "Buscar servicio…")"
    # service_lines corre en una subshell: reconstruir los mapas en esta
    service_lines "$col" "$val" "$extra" >/dev/null
    [[ -z "$sel" ]] && exit 0
    [[ "$sel" == "$BACK" ]] && return 1
    if [[ -n "${URL_MAP[$sel]:-}" ]]; then
        open_url "${URL_MAP[$sel]}" "${STATUS_MAP[$sel]:-activo}"
    elif [[ "$sel" =~ ^https?:// ]]; then
        open_url "$sel" activo
    fi
    exit 0
}

# La primera opción abre la página de toda la tailnet, por encima de los hosts.
hosts_menu() {
    local sel h
    while true; do
        sel="$({ printf '%s\n' "$TAILNET" "$BACK"
                 for h in sinope nas-btb; do
                     printf "󰒋   %-28s (%s)  ▸\n" "$(host_label "$h")" "$(count_where 5 "$h")"
                 done; } | pick "󰒋 Hosts ❯ " "Elegir host…")"
        [[ -z "$sel" ]] && exit 0
        [[ "$sel" == "$TAILNET" ]] && open_url "$TAILNET_URL" activo
        [[ "$sel" == "$BACK" ]] && return 1
        for h in sinope nas-btb; do
            if [[ "$sel" == *"$(host_label "$h") "* ]]; then
                service_menu "󰒋 $(host_label "$h") ❯ " 5 "$h" category || continue 2
            fi
        done
    done
}

# Acceso directo a un host (compatibilidad: launch-homelab-menu.sh sinope|nas-btb)
case "${1:-}" in
    sinope) service_menu "󰒋 Sinope ❯ " 5 sinope category || true ;;
    nas-btb|btb) service_menu "󰒋 NAS-BTB ❯ " 5 nas-btb category || true ;;
esac

SEARCH_ALL="󰍉   Buscar en todo"
while true; do
    sel="$({ for entry in "${CATEGORIES[@]}"; do
                 cat_name="${entry%%|*}"; cat_icon="${entry##*|}"
                 printf "%s   %-28s (%s)  ▸\n" "$cat_icon" "$cat_name" "$(count_where 4 "$cat_name")"
             done
             printf "󰒋   %-28s ▸\n" "Hosts"
             printf '%s\n' "$SEARCH_ALL"; } | pick "󰒋 Servicios ❯ " "Elegir categoría, host o «Buscar en todo»…")"
    [[ -z "$sel" ]] && exit 0
    if [[ "$sel" == "$SEARCH_ALL" ]]; then
        service_menu "󰍉 Todos ❯ " 0 "" both || continue
    elif [[ "$sel" == *"Hosts "* ]]; then
        hosts_menu || continue
    else
        for entry in "${CATEGORIES[@]}"; do
            cat_name="${entry%%|*}"; cat_icon="${entry##*|}"
            if [[ "$sel" == "$cat_icon   $cat_name "* ]]; then
                service_menu "$cat_icon $cat_name ❯ " 4 "$cat_name" host || continue 2
            fi
        done
    fi
done
