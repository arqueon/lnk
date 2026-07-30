#!/usr/bin/env bash
# Opción A: Matriz 2x2 nativa en una sola ventana de Kitty con 4 colores de fondo

SESSION_FILE=$(mktemp /tmp/kitty-quad.XXXXXX.session)
USER_SHELL="${SHELL:-zsh}"

cat << EOF > "$SESSION_FILE"
layout grid

# Panel 1: Superior Izquierdo (Verde Oscuro)
launch --title=Verde sh -c "kitty @ set-colors background=#0c2816; exec $USER_SHELL"

# Panel 2: Superior Derecho (Azul Oscuro)
launch --title=Azul sh -c "kitty @ set-colors background=#0a192f; exec $USER_SHELL"

# Panel 3: Inferior Izquierdo (Ámbar / Café Oscuro)
launch --title=Ambar sh -c "kitty @ set-colors background=#2a1b08; exec $USER_SHELL"

# Panel 4: Inferior Derecho (Púrpura / Tinto Oscuro)
launch --title=Purpura sh -c "kitty @ set-colors background=#200c28; exec $USER_SHELL"
EOF

kitty --app-id kitty-quad --session "$SESSION_FILE"

rm -f "$SESSION_FILE"
