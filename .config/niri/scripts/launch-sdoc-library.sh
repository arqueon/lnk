#!/bin/bash

# Encontrar el binario de sdoc
if [ -f "$HOME/.sdocs/bin/sdoc" ]; then
    SDOC_BIN="$HOME/.sdocs/bin/sdoc"
elif [ -f "$HOME/.local/bin/sdoc" ]; then
    SDOC_BIN="$HOME/.local/bin/sdoc"
else
    SDOC_BIN="sdoc"
fi

# Evitar que abra el navegador al arrancar el agente de SmallDocs
# SmallDocs llama a xdg-open en Linux para abrir la interfaz.
# Creamos un xdg-open de mentira que no hace nada.
DUMMY_DIR="/tmp/sdoc-noop"
mkdir -p "$DUMMY_DIR"
ln -sf /bin/true "$DUMMY_DIR/xdg-open"

# Añadir el xdg-open dummy al inicio del PATH y lanzar sdoc library
PATH="$DUMMY_DIR:$PATH" exec "$SDOC_BIN" library > /dev/null 2>&1
