#!/usr/bin/env bash
# Alt+Espacio (override en user-common.kdl, gana sobre dms/binds.kdl aunque DMS lo regenere).
# - Ventana enfocada = kitty con un cliente herdr dentro → buscador de herdr (plugin herdr-navigator).
# - Cualquier otra ventana → Spotlight Bar de DMS (también en Mod+Alt+Espacio).

ventana=$(niri msg -j focused-window 2>/dev/null)
app=$(jq -r '.app_id // empty' <<<"$ventana")
pid=$(jq -r '.pid // empty' <<<"$ventana")

tiene_herdr() {
    local p
    for p in $(pgrep -x herdr); do
        while [[ -n "$p" && "$p" != 1 ]]; do
            [[ "$p" == "$1" ]] && return 0
            p=$(ps -o ppid= -p "$p" | tr -d ' ')
        done
    done
    return 1
}

if [[ "$app" == kitty && -n "$pid" ]] && tiene_herdr "$pid" \
   && herdr plugin action invoke open --plugin herdr-navigator >/dev/null 2>&1; then
    exit 0
fi
exec dms ipc call spotlight-bar toggle
