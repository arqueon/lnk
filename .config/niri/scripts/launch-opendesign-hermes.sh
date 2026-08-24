#!/usr/bin/env bash
set -euo pipefail

find_appimage() {
  command -v shelly >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1

  shelly list appimage --json 2>/dev/null \
    | jq -r '
        map(select(
          (.DesktopName // "") == "Open Design"
          and ((.Name // "") | contains("hermes-pilot"))
        ))
        | last
        | .Path // empty
      '
}

appimage="$(find_appimage || true)"

if [[ "${1:-}" == "--available" ]]; then
  [[ -n "${appimage}" && -x "${appimage}" ]]
  exit $?
fi

if [[ -z "${appimage}" || ! -x "${appimage}" ]]; then
  notify-send -u critical "OpenDesign + Hermes" \
    "El piloto no está instalado con Shelly en este equipo."
  exit 1
fi

# OpenDesign's Hermes adapter is ACP over stdio. Keep the user's local Hermes
# first on PATH so the app does not silently fall back to another installation.
export PATH="${HOME}/.local/bin:${PATH:-/usr/local/bin:/usr/bin:/bin}"

# The native pilot is a portable AppImage. Extraction avoids depending on FUSE
# and matches the Linux execution path used during validation.
exec "${appimage}" --appimage-extract-and-run
