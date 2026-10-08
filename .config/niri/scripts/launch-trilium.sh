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

# Ejecuta (o, con TRILIUM_LAUNCHER_DRYRUN=1, solo muestra) el comando elegido.
run() {
  if [[ -n "${TRILIUM_LAUNCHER_DRYRUN:-}" ]]; then
    printf '%s\n' "$*"
    exit 0
  fi
  exec "$@"
}

if [[ -n "${app_path}" && -x "${app_path}" ]]; then
  run "${app_path}" "$@"
fi

# Fallback a binarios del sistema (paquete AUR triliumnext-bin: /usr/bin/triliumnext).
# Rutas ABSOLUTAS a propósito: ~/.local/bin/trilium es un wrapper que vuelve a llamar a
# este script, y resolver "trilium" por PATH producía un bucle infinito de exec cuando no
# había AppImage ni paquete (584 re-ejecuciones en 2 s, sin llegar al aviso de error).
IFS=: read -r -a system_bins <<< "${TRILIUM_SYSTEM_BINS:-/usr/bin/triliumnext:/usr/bin/trilium:/opt/trilium/trilium:/opt/triliumnext/trilium}"
for bin in "${system_bins[@]}"; do
  if [[ -x "${bin}" ]]; then
    run "${bin}" "$@"
  fi
done

notify-send -u critical "Trilium Notes" \
  "No se encontró la AppImage de Trilium administrada por Shelly ni el paquete triliumnext-bin."
exit 1
