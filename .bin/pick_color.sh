#!/bin/bash

# 1. Ejecutar 'niri msg pick-color' y almacenar el resultado en una variable
COLOR=$(niri msg pick-color)

# 2. Verificar si se obtuvo un color (es decir, si el usuario no canceló)
if [ -n "$COLOR" ]; then
    # 3. Copiar el color obtenido al clipboard usando wl-copy
    echo -n "$COLOR" | wl-copy
    
    # 4. Generar la notificación, incluyendo el color copiado en el cuerpo
    notify-send "Color copiado" "$COLOR se ha enviado al portapapeles."
else
    # Opcional: Notificar si la selección fue cancelada
    notify-send "Selección cancelada" "No se copió ningún color."
fi

