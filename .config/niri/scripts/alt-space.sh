#!/usr/bin/env bash
# Alt+Espacio (override en user-common.kdl, gana sobre dms/binds.kdl aunque DMS lo regenere).
# - Ventana enfocada = kitty con TUIOS en primer plano en la pestaña activa → lanzador de TUIOS
#   (niri se come Alt+Space, así que se teclea su chord Ctrl+B a por el control remoto de kitty). 2026-11-07
# - Ventana enfocada = kitty con un cliente herdr dentro → buscador de herdr (plugin herdr-navigator).
# - Cualquier otra ventana → Spotlight Bar de DMS (también en Mod+Alt+Espacio).

ventana=$(niri msg -j focused-window 2>/dev/null)
app=$(jq -r '.app_id // empty' <<<"$ventana")
pid=$(jq -r '.pid // empty' <<<"$ventana")
kitty_sock="unix:${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/kitty-${pid}.sock"   # listen_on de kitty.conf

# id de la ventana kitty activa si su proceso en primer plano es TUIOS (cliente: tuios / tuios attach …)
tuios_ventana() {
    kitty @ --to "$kitty_sock" ls 2>/dev/null | jq -er '
        first(.[] | select(.is_focused) | .tabs[] | select(.is_active) | .windows[]
              | select(.is_active)
              | select(any(.foreground_processes[]; (.cmdline[0] // "") | test("(^|/)tuios$")))
              | .id)'
}

if [[ "$app" == kitty && -n "$pid" ]] && kid=$(tuios_ventana) \
   && printf '\x02a' | kitty @ --to "$kitty_sock" send-text --match "id:$kid" --stdin >/dev/null 2>&1; then
    exit 0
fi

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
