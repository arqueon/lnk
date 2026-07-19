#!/bin/bash
# ─── sdoc-open.sh ───────────────────────────────────────────────
# Wrapper unificado de SmallDocs para integración con el escritorio.
#
# Uso:
#   sdoc-open.sh              → levanta el agente de library (headless, sin navegador)
#   sdoc-open.sh <archivo.md> → abre el archivo en modo bridge (editable)
#
# Llamado desde:
#   • startup.kdl   (sin args → library agent)
#   • sdoc.desktop  (con %f  → bridge editable)
# ────────────────────────────────────────────────────────────────

# ── Localizar el binario de sdoc ──
if [ -f "$HOME/.sdocs/bin/sdoc" ]; then
    SDOC_BIN="$HOME/.sdocs/bin/sdoc"
elif [ -f "$HOME/.local/bin/sdoc" ]; then
    SDOC_BIN="$HOME/.local/bin/sdoc"
else
    SDOC_BIN="sdoc"
fi

LIBRARY_PORT=47843

# ── Función: verificar si el agente de library está vivo ──
library_alive() {
    curl -sf --max-time 1 "http://127.0.0.1:${LIBRARY_PORT}/api/library/health" > /dev/null 2>&1
}

# ── Función: levantar el agente de library en modo headless ──
start_library_headless() {
    # Enmascarar xdg-open para que sdoc library no abra el navegador
    local dummy_dir="/tmp/sdoc-noop"
    mkdir -p "$dummy_dir"
    ln -sf /bin/true "$dummy_dir/xdg-open"
    PATH="$dummy_dir:$PATH" exec "$SDOC_BIN" library > /dev/null 2>&1
}

# ── Sin argumentos: modo startup (levantar library agent) ──
if [ -z "$1" ]; then
    start_library_headless
    exit 0
fi

# ── Con archivo: modo bridge (abrir editable) ──
FILE="$1"

# Asegurar que el agente de library esté corriendo para que
# el archivo quede indexado. Si no está vivo, levantarlo
# en segundo plano (headless) antes de abrir el bridge.
if ! library_alive; then
    local_dummy="/tmp/sdoc-noop"
    mkdir -p "$local_dummy"
    ln -sf /bin/true "$local_dummy/xdg-open"
    PATH="$local_dummy:$PATH" "$SDOC_BIN" library > /dev/null 2>&1 &
    disown
    # Esperar brevemente a que el agente arranque
    for i in $(seq 1 10); do
        library_alive && break
        sleep 0.3
    done
fi

# Abrir el archivo en modo bridge (editable, WebSocket bidireccional).
# El proceso queda vivo hasta que el usuario cierra la pestaña.
exec "$SDOC_BIN" bridge "$FILE"
