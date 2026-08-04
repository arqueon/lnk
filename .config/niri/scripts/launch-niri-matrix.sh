#!/usr/bin/env bash
# Script parametrizable para matrices de Kitty en Niri (4 o 6 ventanas)

COUNT="${1:-6}"
TARGET_WORKSPACE="${2:-agents}"

# 0. Cambiar al workspace objetivo de forma síncrona
niri msg action focus-workspace "$TARGET_WORKSPACE"
sleep 0.35

if [ "$COUNT" -eq 4 ]; then
    APP_ID="kitty-quad-niri"

    # 1. Columna 1 — Abrir Ventana 1 (Verde)
    niri msg action spawn -- env KITTY_HEX_BG=#0c2816 kitty --app-id "$APP_ID" --title "Verde (W1)" -o background=#0c2816
    sleep 0.35

    # 2. Columna 1 — Abrir Ventana 2 (Azul)
    niri msg action spawn -- env KITTY_HEX_BG=#0a192f kitty --app-id "$APP_ID" --title "Azul (W2)" -o background=#0a192f
    sleep 0.35

    # 3. Consumir W2 en Columna 1, apilar verticalmente y fijar ancho al 50%
    niri msg action consume-or-expel-window-left
    sleep 0.15
    niri msg action set-column-display normal
    sleep 0.1
    niri msg action set-column-width "50%"
    sleep 0.15

    # 4. Columna 2 — Abrir Ventana 3 (Ámbar)
    niri msg action spawn -- env KITTY_HEX_BG=#2a1b08 kitty --app-id "$APP_ID" --title "Ámbar (W3)" -o background=#2a1b08
    sleep 0.35

    # 5. Columna 2 — Abrir Ventana 4 (Púrpura)
    niri msg action spawn -- env KITTY_HEX_BG=#200c28 kitty --app-id "$APP_ID" --title "Púrpura (W4)" -o background=#200c28
    sleep 0.35

    # 6. Consumir W4 en Columna 2, apilar verticalmente y fijar ancho al 50%
    niri msg action consume-or-expel-window-left
    sleep 0.15
    niri msg action set-column-display normal
    sleep 0.1
    niri msg action set-column-width "50%"
    sleep 0.15

else
    APP_ID="kitty-hex"

    # Columna 1
    niri msg action spawn -- env KITTY_HEX_BG=#0c2816 kitty --app-id "$APP_ID" --title "Verde (Niri W1)" -o background=#0c2816
    sleep 0.35
    niri msg action spawn -- env KITTY_HEX_BG=#0a192f kitty --app-id "$APP_ID" --title "Azul (Niri W2)" -o background=#0a192f
    sleep 0.35
    niri msg action consume-or-expel-window-left
    sleep 0.15
    niri msg action set-column-display normal
    sleep 0.1
    niri msg action set-column-width "33.333%"
    sleep 0.15

    # Columna 2
    niri msg action spawn -- env KITTY_HEX_BG=#2a1b08 kitty --app-id "$APP_ID" --title "Ámbar (Niri W3)" -o background=#2a1b08
    sleep 0.35
    niri msg action spawn -- env KITTY_HEX_BG=#200c28 kitty --app-id "$APP_ID" --title "Púrpura (Niri W4)" -o background=#200c28
    sleep 0.35
    niri msg action consume-or-expel-window-left
    sleep 0.15
    niri msg action set-column-display normal
    sleep 0.1
    niri msg action set-column-width "33.333%"
    sleep 0.15

    # Columna 3
    niri msg action spawn -- env KITTY_HEX_BG=#052628 kitty --app-id "$APP_ID" --title "Cian (Niri W5)" -o background=#052628
    sleep 0.35
    niri msg action spawn -- env KITTY_HEX_BG=#28081a kitty --app-id "$APP_ID" --title "Granate (Niri W6)" -o background=#28081a
    sleep 0.35
    niri msg action consume-or-expel-window-left
    sleep 0.15
    niri msg action set-column-display normal
    sleep 0.1
    niri msg action set-column-width "33.333%"
    sleep 0.15
fi

# Posicionar el foco al inicio del workspace (Columna 1) y centrar columnas visibles
niri msg action focus-column-first
sleep 0.1
niri msg action center-visible-columns
