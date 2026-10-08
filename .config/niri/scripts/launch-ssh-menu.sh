#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  launch-ssh-menu.sh — Menú de conexiones SSH entre casa / oficina / laptop
# ═══════════════════════════════════════════════════════════════════
# Tailscale (normal) y VPN Fortinet (respaldo). Oculta el equipo actual.
# Referencia: página/doc «Accesos entre oficina, casa y laptop» (7-oct-2026).
# Prueba sin ejecutar: SSH_MENU_DRYRUN=1 SSH_MENU_PICK=<texto> SSH_MENU_HOST=<host> ./launch-ssh-menu.sh

set -euo pipefail

me="${SSH_MENU_HOST:-$(hostname)}"
case "$me" in
    *ofi*)    here=ofi ;;
    *laptop*) here=laptop ;;
    casa*)    here=casa ;;
    *)        here=otro ;;
esac

# Entradas: etiqueta | categoría | descripción | comando (se ejecuta en terminal)
ITEMS=()
add() { ITEMS+=("$1"$'\t'"$2"$'\t'"$3"$'\t'"$4"); }

# — Tailscale (siempre que no sea el propio equipo)
[[ $here != ofi    ]] && add "󰢹  Oficina"   "Tailscale" "ssh cachyos-ofi"    "ssh cachyos-ofi"
[[ $here != casa   ]] && add "󰋜  Casa"      "Tailscale" "ssh casa-cachyos"  "ssh casa-cachyos"
[[ $here != laptop ]] && add "󰌢  Laptop"    "Tailscale" "ssh ruben-laptop"  "ssh ruben-laptop"
add "󰒋  Sinope"   "Tailscale" "ssh sinope"        "ssh sinope"

# — Respaldo por VPN Fortinet
if [[ $here == casa || $here == laptop ]]; then
    add "󰖂  Oficina (VPN)" "VPN" "ssh cachyos-ofi-vpn · VPN arriba aquí" "ssh cachyos-ofi-vpn"
    add "󰖂  Levantar VPN"  "VPN" "sudo openfortivpn (Ctrl+C la cierra)"  "sudo pkill openfortivpn; sudo openfortivpn"
fi
if [[ $here == ofi ]]; then
    add "󰋜  Casa (túnel)"   "VPN" "ssh casa-tunel · VPN arriba en casa"    "ssh casa-tunel"
    add "󰌢  Laptop (túnel)" "VPN" "ssh laptop-tunel · VPN arriba en laptop" "ssh laptop-tunel"
    add "󰒍  Túneles activos" "Diagnóstico" "ss -tln | grep 2222/2223" "ss -tln | grep -E '2222|2223' || echo 'Sin túneles conectados'"
fi

# — Diagnóstico
add "󰖂  Estado VPN"   "Diagnóstico" "ip -br addr | grep ppp" "ip -br addr | grep ppp || echo 'VPN abajo (sin ppp0)'"
if [[ $here == casa || $here == laptop ]]; then
    add "󰑓  Reiniciar túnel" "Diagnóstico" "systemctl --user restart tunel-oficina" "systemctl --user restart tunel-oficina && systemctl --user status tunel-oficina --no-pager | head -12"
    add "󰋽  Log del túnel"   "Diagnóstico" "journalctl --user -u tunel-oficina" "journalctl --user -u tunel-oficina -n 20 --no-pager"
fi
add "󰅖  Matar VPN" "Diagnóstico" "sudo pkill openfortivpn" "sudo pkill openfortivpn && echo 'VPN cerrada'"

declare -A CMD
menu=""
for it in "${ITEMS[@]}"; do
    IFS=$'\t' read -r label cat desc cmd <<< "$it"
    line="$(printf "%-22.22s │ %-11.11s │ %s" "$label" "$cat" "$desc")"
    CMD["$line"]="$cmd"
    menu+="$line"$'\n'
done
menu="${menu%$'\n'}"

if [[ -n "${SSH_MENU_PICK:-}" ]]; then
    choice="$(grep -F -m1 -- "$SSH_MENU_PICK" <<< "$menu" || true)"
else
    choice="$(printf '%s\n' "$menu" | fuzzel --dmenu --prompt "󰣀 SSH ($here) ❯ " \
        --placeholder "Conectar a… (ofi, casa, laptop, vpn)" --width=100 --lines=14 \
        --line-height=26 --horizontal-pad=20 --vertical-pad=12 --match-mode=fzf || true)"
fi
[[ -n "$choice" ]] || exit 0
cmd="${CMD[$choice]}"

if [[ -n "${SSH_MENU_DRYRUN:-}" ]]; then printf '%s\n' "$cmd"; exit 0; fi

terminal="${TERMINAL:-}"
if [[ -z "$terminal" ]]; then
    for c in kitty foot alacritty wezterm; do command -v "$c" >/dev/null && { terminal="$c"; break; }; done
fi
[[ -n "$terminal" ]] || { notify-send -u critical "Menú SSH" "No se encontró terminal"; exit 1; }

# La terminal queda abierta al terminar para poder leer errores.
exec "$terminal" -e bash -c "$cmd"'; rc=$?; [ $rc -ne 0 ] && { echo; read -rp "Terminó con código $rc — Enter para cerrar"; }; exit $rc'
