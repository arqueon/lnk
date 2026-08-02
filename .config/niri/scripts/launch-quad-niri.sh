#!/usr/bin/env bash
# Ventanas independientes de Kitty organizadas en matriz 3x2 (6 instancias) en workspace "agents" (DP-2)

# 0. Enfocar el workspace "agents" en DP-2
niri msg action focus-workspace "agents"
sleep 0.2

# 1. Columna 1 — Abrir Ventana 1 (Verde)
niri msg action spawn -- kitty --app-id kitty-hex --title "Verde (Niri W1)" --env KITTY_HEX_BG=#0c2816 --override background=#0c2816
sleep 0.25

# 2. Columna 1 — Abrir Ventana 2 (Azul)
niri msg action spawn -- kitty --app-id kitty-hex --title "Azul (Niri W2)" --env KITTY_HEX_BG=#0a192f --override background=#0a192f
sleep 0.25

# 3. Consumir Ventana 2 dentro de Columna 1
niri msg action focus-column-left
sleep 0.1
niri msg action consume-window-into-column
sleep 0.1
niri msg action toggle-column-tabbed-display
sleep 0.15

# 4. Columna 2 — Abrir Ventana 3 (Ámbar)
niri msg action spawn -- kitty --app-id kitty-hex --title "Ámbar (Niri W3)" --env KITTY_HEX_BG=#2a1b08 --override background=#2a1b08
sleep 0.25

# 5. Columna 2 — Abrir Ventana 4 (Púrpura)
niri msg action spawn -- kitty --app-id kitty-hex --title "Púrpura (Niri W4)" --env KITTY_HEX_BG=#200c28 --override background=#200c28
sleep 0.25

# 6. Consumir Ventana 4 dentro de Columna 2
niri msg action focus-column-left
sleep 0.1
niri msg action consume-window-into-column
sleep 0.1
niri msg action toggle-column-tabbed-display
sleep 0.15

# 7. Columna 3 — Abrir Ventana 5 (Cian)
niri msg action spawn -- kitty --app-id kitty-hex --title "Cian (Niri W5)" --env KITTY_HEX_BG=#052628 --override background=#052628
sleep 0.25

# 8. Columna 3 — Abrir Ventana 6 (Granate)
niri msg action spawn -- kitty --app-id kitty-hex --title "Granate (Niri W6)" --env KITTY_HEX_BG=#28081a --override background=#28081a
sleep 0.25

# 9. Consumir Ventana 6 dentro de Columna 3
niri msg action focus-column-left
sleep 0.1
niri msg action consume-window-into-column
sleep 0.1
niri msg action toggle-column-tabbed-display
sleep 0.15

# 10. Posicionar el foco al inicio (Columna 1)
niri msg action focus-column-first
