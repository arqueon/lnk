#!/usr/bin/env bash
# wake-monitors.sh: forzar encendido de monitores y refrescar salidas en Niri + DMS
set -euo pipefail

# 1. Enviar señal DPMS de encendido a todos los monitores en Niri
niri msg action power-on-monitors >/dev/null 2>&1 || true

# 2. Refrescar estado de salidas en DMS para recomponer barras y superficies
dms ipc call outputs refresh >/dev/null 2>&1 || true

# 3. Notificación informativa si el entorno gráfico está disponible
if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "Monitor" "Monitores reactivados" "Señal DPMS reanudada y salidas refrescadas" 2>/dev/null || true
fi
