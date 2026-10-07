#!/usr/bin/env bash
set -euo pipefail

# Launcher de Trilium Notes para Niri WM
# Detecta dinámicamente la AppImage instalada por Shelly independientemente
# de cambios de versión o nombre, con fallback a directorios locales o binario del sistema.

find_shelly_appimage() {
  command -v shelly >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1

  shelly list appimage --json 2>/dev/null \
    | jq -r '
        map(select(
          ((.DesktopName // "") | test("Trilium"; "i")) or
          ((.Name // "") | test("Trilium"; "i"))
        ))
        | last
        | .Path // empty
      '
}

app_path="$(find_shelly_appimage || true)"

# Fallback si Shelly no devuelve ruta válida
if [[ -z "${app_path}" || ! -x "${app_path}" ]]; then
  app_path="$(find -L "${HOME}/.local/bin" "${HOME}/Applications" "${HOME}/Downloads" -maxdepth 1 -type f -iname '*trilium*.appimage' 2>/dev/null \
    | sort -V \
    | tail -n 1 || true)"
fi

if [[ -n "${app_path}" && -x "${app_path}" ]]; then
  exec "${app_path}" "$@"
fi

# Fallback a binarios del sistema
if command -v triliumnext >/dev/null 2>&1; then
  exec triliumnext "$@"
elif command -v trilium >/dev/null 2>&1 && [[ "$(command -v trilium)" != "$0" ]]; then
  exec trilium "$@"
fi

notify-send -u critical "Trilium Notes" \
  "No se encontró la AppImage de Trilium administrada por Shelly ni ejecutable en el sistema."
exit 1
