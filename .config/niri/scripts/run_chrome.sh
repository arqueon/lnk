#!/bin/bash

# Lista de binarios en orden de prioridad (primera instalada gana)
versiones=(
    "google-chrome-canary"
    "google-chrome-beta"
    "google-chrome-dev"
    "google-chrome-stable"
)

# Buscar y ejecutar la primera opción disponible en el PATH
for cromo in "${versiones[@]}"; do
    if command -v "$cromo" >/dev/null 2>&1; then
        exec "$cromo" "$@"
    fi
done

echo "No se detectó ninguna instalación de Google Chrome en este sistema."
exit 1