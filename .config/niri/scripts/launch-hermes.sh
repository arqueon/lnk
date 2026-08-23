#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
hermes_cli="${script_dir}/hermes-sinope"

host_name="$(hostnamectl --static 2>/dev/null || hostname 2>/dev/null || true)"
current_user="${USER:-$(id -un)}"

if [[ "${host_name}" == abdel* || "${current_user}" == "abdel" ]]; then
  profile="hermes-abdel"
  identity="Hermina · Abdel (hermes-abdel@sinope)"
else
  profile="hermes"
  identity="Hermes · Rubén (hermes@sinope)"
fi

open_url() {
  if [[ -x "${script_dir}/run_chrome.sh" ]]; then
    exec "${script_dir}/run_chrome.sh" --app="$1"
  fi
  exec xdg-open "$1"
}

show_status() {
  local status_rc

  set +e
  "${hermes_cli}" "${profile}" status
  status_rc=$?
  set -e

  printf '\n'
  if [[ -t 0 ]]; then
    read -r -n 1 -s -p "Pulsa cualquier tecla para cerrar…" || true
    printf '\n'
  fi
  return "${status_rc}"
}

if [[ "${1:-}" == "--show-status" ]]; then
  show_status
  exit $?
fi

if [[ "${1:-}" =~ ^https?:// ]]; then
  open_url "$1"
fi

choices=$'WebUI comunitaria\twebui\nDashboard oficial\tdashboard\nDesktop oficial\tdesktop\nTUI oficial persistente (tmux)\ttui\nHermes Gate (sesiones tmux)\tgate\nHermes Workspace\tworkspace\nHermes UI PWA\tpwa\nOpen WebUI (pesada)\topen-webui\nEstado de interfaces\tstatus\nPreparar tmux remoto (UTF-8 + portapapeles)\ttmux-setup\nDetener laboratorios y túneles\tstop-labs'

select_choice() {
  local selected=""
  if command -v fuzzel >/dev/null 2>&1; then
    selected="$(printf '%s\n' "${choices}" | cut -f1 | fuzzel --dmenu --prompt="${identity} › " --lines=11 --width=56 2>/dev/null || true)"
  elif command -v rofi >/dev/null 2>&1; then
    selected="$(printf '%s\n' "${choices}" | cut -f1 | rofi -dmenu -i -p "${identity}" 2>/dev/null || true)"
  elif command -v zenity >/dev/null 2>&1; then
    selected="$(printf '%s\n' "${choices}" | cut -f1 | zenity --list --title="Interfaces remotas de Hermes" --text="Cuenta detectada: ${identity}" --column="Interfaz" --height=520 --width=560 2>/dev/null || true)"
  elif command -v kdialog >/dev/null 2>&1; then
    local -a menu_args=()
    local label action
    while IFS=$'\t' read -r label action; do
      menu_args+=("${action}" "${label}")
    done <<<"${choices}"
    action="$(kdialog --title "${identity}" --menu "Selecciona una interfaz" "${menu_args[@]}" 2>/dev/null || true)"
    printf '%s\n' "${action}"
    return
  else
    notify-send -u critical "Hermes remoto" "No hay fuzzel, rofi, zenity ni kdialog para mostrar el selector."
    return 1
  fi

  [[ -n "${selected}" ]] || return 0
  awk -F '\t' -v label="${selected}" '$1 == label { print $2; exit }' <<<"${choices}"
}

action="$(select_choice)"
[[ -n "${action}" ]] || exit 0

if [[ "${action}" == open-webui ]]; then
  notify-send -t 15000 "Hermes remoto" \
    "Iniciando Open WebUI; el primer arranque puede tardar cerca de un minuto."
fi

terminal="${TERMINAL:-}"
if [[ -z "${terminal}" ]]; then
  for candidate in kitty foot alacritty wezterm; do
    if command -v "${candidate}" >/dev/null 2>&1; then
      terminal="${candidate}"
      break
    fi
  done
fi

case "${action}" in
  tui|gate)
    if [[ -z "${terminal}" ]]; then
      notify-send -u critical "Hermes remoto" "No se encontró una terminal compatible."
      exit 1
    fi
    exec "${terminal}" -e "${hermes_cli}" "${profile}" "${action}"
    ;;
  status)
    if [[ -z "${terminal}" ]]; then
      notify-send -u critical "Hermes remoto" "No se encontró una terminal compatible."
      exit 1
    fi
    exec "${terminal}" -e "${script_dir}/launch-hermes.sh" --show-status
    ;;
  desktop)
    exec "${hermes_cli}" "${profile}" desktop
    ;;
  *)
    if output="$("${hermes_cli}" "${profile}" "${action}" 2>&1)"; then
      [[ -n "${output}" ]] && notify-send "Hermes remoto" "${output}"
    else
      notify-send -u critical "Hermes remoto" "${output:-No se pudo ejecutar ${action}.}"
      exit 1
    fi
    ;;
esac
