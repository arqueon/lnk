#!/usr/bin/env bash
# Hoja de atajos de herdr en ventana flotante (Mod+Alt+/). La genera herdr-atajos desde la config real.
exec kitty --class herdr-atajos --app-id herdr-atajos --title "herdr · atajos" "$HOME/.local/bin/herdr-atajos" --esperar
