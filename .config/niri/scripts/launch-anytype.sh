#!/usr/bin/env bash
set -euo pipefail

find_shelly_appimage() {
  command -v shelly >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1

  shelly list appimage --json 2>/dev/null \
    | jq -r '
        map(select((.DesktopName // "") == "Anytype"))
        | last
        | .Path // empty
      '
}

app_path="$(find_shelly_appimage || true)"

# Compatibility fallback for stations not migrated to Shelly yet.
if [[ -z "${app_path}" || ! -x "${app_path}" ]]; then
  app_path="$(find "${HOME}/Applications" -maxdepth 1 -type f -name 'anytype_*' -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | head -n 1 \
    | cut -d' ' -f2- || true)"
fi

if [[ -z "${app_path}" || ! -x "${app_path}" ]]; then
  notify-send -u critical "Anytype" \
    "No se encontró una AppImage de Anytype administrada por Shelly."
  exit 1
fi

# Restart the single-instance app so Mod+F10 always brings up a fresh window.
pkill -x anytype >/dev/null 2>&1 || true
sleep 1

args=()
host_name="$(hostnamectl --static 2>/dev/null || hostname 2>/dev/null || true)"
if [[ "${host_name}" == abdel* ]]; then
  args+=(--ozone-platform=x11)
fi

cd -- "$(dirname -- "${app_path}")"
exec "${app_path}" "${args[@]}" >/dev/null 2>&1
