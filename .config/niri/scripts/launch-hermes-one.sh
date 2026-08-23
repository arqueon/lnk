#!/usr/bin/env bash
set -euo pipefail

desktop_name="Hermes One (Sinope)"

find_appimage() {
  command -v shelly >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1

  shelly list appimage --json 2>/dev/null \
    | jq -r --arg desktop_name "${desktop_name}" \
        'map(select(.DesktopName == $desktop_name)) | sort_by(.Version) | last | .Name // empty'
}

app_name="$(find_appimage || true)"

if [[ "${1:-}" == "--available" ]]; then
  [[ -n "${app_name}" ]]
  exit
fi

if [[ -z "${app_name}" ]]; then
  notify-send -u critical "Hermes One" \
    "No está instalado con Shelly para este usuario."
  exit 1
fi

exec shelly run appimage "${app_name}" --no-confirm
