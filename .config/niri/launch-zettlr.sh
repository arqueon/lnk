#!/bin/bash

# 1. Matar procesos anteriores para evitar conflictos
pkill -f "zettlr" || true
sleep 1

# 2. Ejecutar la aplicación
# Usamos el binario del sistema
zettlr > /dev/null 2>&1 &

# Desvincular el proceso para que siga vivo tras cerrar el script
disown
