#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
port=3080
base_url="http://127.0.0.1:${port}"
log_file="/tmp/dsh-web.log"

# Cargar DEEPSEEK_API_KEY desde environment.d si no está exportada
if [[ -z "${DEEPSEEK_API_KEY:-}" && -f "${HOME}/.config/environment.d/deepseek.conf" ]]; then
  # shellcheck disable=SC1090
  source "${HOME}/.config/environment.d/deepseek.conf"
  export DEEPSEEK_API_KEY
fi

is_running() {
  curl -s -m 1 -o /dev/null "${base_url}/" 2>/dev/null
}

target_url="${base_url}"

if ! is_running; then
  dsh_bin="${HOME}/.local/bin/dsh"
  if [[ ! -x "${dsh_bin}" ]]; then
    dsh_bin="$(command -v dsh || true)"
  fi

  if [[ -z "${dsh_bin}" || ! -x "${dsh_bin}" ]]; then
    notify-send -u critical "DeepSeek Harness" "No se encontró el ejecutable dsh en ~/.local/bin ni en PATH."
    exit 1
  fi

  notify-send -t 3000 "DeepSeek Harness" "Iniciando servidor web dsh..."
  nohup "${dsh_bin}" web --no-open >"${log_file}" 2>&1 &

  # Esperar hasta 6 segundos a que el servidor comience a escuchar
  for _ in {1..30}; do
    if is_running; then
      break
    fi
    sleep 0.2
  done

  if ! is_running; then
    notify-send -u critical "DeepSeek Harness" "El servidor no respondió a tiempo. Revisa ${log_file}"
    exit 1
  fi

  # Si se emitió una URL con token de inicio, usarla para la sesión del navegador
  if [[ -f "${log_file}" ]]; then
    token_url="$(grep -o "http://127\.0\.0\.1:${port}/?token=[^ ]*" "${log_file}" | tail -n 1 || true)"
    if [[ -n "${token_url}" ]]; then
      target_url="${token_url}"
    fi
  fi
fi

if [[ -x "${script_dir}/run_chrome.sh" ]]; then
  exec "${script_dir}/run_chrome.sh" --app="${target_url}"
else
  for chrome_bin in google-chrome-beta google-chrome-stable google-chrome chromium; do
    if command -v "${chrome_bin}" >/dev/null 2>&1; then
      exec "${chrome_bin}" --no-default-browser-check --new-window --app="${target_url}"
    fi
  done
  notify-send -u critical "DeepSeek Harness" "No se encontró Chrome para abrir la webapp."
  exit 1
fi
