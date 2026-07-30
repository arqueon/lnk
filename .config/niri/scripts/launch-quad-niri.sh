#!/usr/bin/env bash
# Opción B: 4 ventanas independientes de Kitty organizadas en matriz 2x2 en Niri

# 1. Abrir Ventana 1 (Verde) -> Columna 1
niri msg action spawn -- kitty --title "Verde (Niri W1)" --override background=#0c2816
sleep 0.25

# 2. Abrir Ventana 2 (Azul) -> Columna 2
niri msg action spawn -- kitty --title "Azul (Niri W2)" --override background=#0a192f
sleep 0.25

# 3. Consumir Ventana 2 dentro de Columna 1
niri msg action focus-column-left
sleep 0.1
niri msg action consume-window-into-column
sleep 0.1
# Cambiar de vista Pestañas (Tabs) a vista Apilada/Mosaico (Normal vertical)
niri msg action toggle-column-tabbed-display
sleep 0.15

# 4. Abrir Ventana 3 (Ámbar) -> Columna 2
niri msg action spawn -- kitty --title "Ámbar (Niri W3)" --override background=#2a1b08
sleep 0.25

# 5. Abrir Ventana 4 (Púrpura) -> Columna 3
niri msg action spawn -- kitty --title "Púrpura (Niri W4)" --override background=#200c28
sleep 0.25

# 6. Consumir Ventana 4 dentro de Columna 2
niri msg action focus-column-left
sleep 0.1
niri msg action consume-window-into-column
sleep 0.1
# Cambiar de vista Pestañas (Tabs) a vista Apilada/Mosaico (Normal vertical)
niri msg action toggle-column-tabbed-display
