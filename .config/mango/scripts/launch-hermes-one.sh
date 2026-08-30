#!/usr/bin/env bash
set -euo pipefail

desktop_name="Hermes One (Sinope)"

find_appimage() {
  if command -v shelly >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    shelly list appimage --json 2>/dev/null \
      | jq -r --arg desktop_name "${desktop_name}" \
          'map(select(.DesktopName == $desktop_name)) | sort_by(.Version) | last | .Name // empty'
  fi
}

app_name="$(find_appimage || true)"
appimage="$(find -L "${HOME}/.local/bin" -maxdepth 1 -type f -name 'Hermes-One-*-sinope-x86_64.AppImage' -print 2>/dev/null | sort -V | tail -n 1)"

if [[ "${1:-}" == "--available" ]]; then
  [[ -n "${app_name}" || ( -n "${appimage}" && -x "${appimage}" ) ]]
  exit
fi

if [[ -n "${app_name}" ]]; then
  exec shelly run appimage "${app_name}" --no-confirm
elif [[ -n "${appimage}" && -x "${appimage}" ]]; then
  exec "${appimage}" --appimage-extract-and-run
else
  notify-send -u critical "Hermes One" \
    "No se encontró el AppImage para este usuario."
  exit 1
fi
