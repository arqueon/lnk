#!/usr/bin/bash
set -u

export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin"
export XDG_CURRENT_DESKTOP=mango
export XDG_SESSION_DESKTOP=mango
export XDG_SESSION_TYPE=wayland

dbus-update-activation-environment --systemd \
  WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE PATH
systemctl --user import-environment \
  WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE PATH

# Variety descarga y elige fondos; Noctalia los renderiza y genera la paleta.
( sleep 3; exec variety ) &
exec "$HOME/.local/bin/noctalia" --daemon
