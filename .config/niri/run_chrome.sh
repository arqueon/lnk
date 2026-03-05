#!/bin/bash

# Lista de binarios en orden de prioridad descendente
versiones=(
    "google-chrome-stable" 
    "google-chrome-beta" 
    "google-chrome-dev" 
    "google-chrome-unstable" 
    "google-chrome-canary"
)

# Buscar y ejecutar la primera opción disponible en el PATH
for cromo in "${versiones[@]}"; do
    if command -v "$cromo" >/dev/null 2>&1; then
        exec "$cromo" "$@"
    fi
done

echo "No se detectó ninguna instalación de Google Chrome en este sistema."
exit 1