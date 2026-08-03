#!/usr/bin/env bash

# Arranque intencionalmente minimo para la sesion Qtile de emergencia.
set -u

export XDG_CURRENT_DESKTOP=qtile
export XDG_SESSION_DESKTOP=qtile

systemctl --user import-environment \
    DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd \
        DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
fi

polkit_agent=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
if [[ -x "$polkit_agent" ]] && ! pgrep -u "$UID" -f "$polkit_agent" >/dev/null; then
    "$polkit_agent" &
fi
