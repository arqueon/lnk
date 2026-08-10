#!/bin/bash
# Mindwtr Launcher Script (Niri WM)
# Soporta AppImages dinámicos (para sobrevivir a distintas versiones), Flatpak o ejecutable del sistema.

# 1. Buscar el AppImage más reciente en ~/.local/bin, ~/Applications o ~/Downloads
APPIMAGE=$(ls -t "$HOME/.local/bin"/[Mm]indwtr*.AppImage "$HOME/.local/bin"/[Mm]indwtr*.appimage "$HOME/Applications"/[Mm]indwtr*.AppImage "$HOME/Applications"/[Mm]indwtr*.appimage "$HOME/Downloads"/[Mm]indwtr*.AppImage "$HOME/Downloads"/[Mm]indwtr*.appimage 2>/dev/null | grep -v "mindwtr-bridge" | head -n 1)

if [ -n "$APPIMAGE" ] && [ -f "$APPIMAGE" ]; then
    chmod +x "$APPIMAGE" 2>/dev/null
    exec "$APPIMAGE" "$@"
fi

# 2. Si no hay AppImage, intentar con Flatpak
if command -v flatpak >/dev/null 2>&1 && flatpak list --app 2>/dev/null | grep -q "tech.dongdongbh.mindwtr"; then
    exec flatpak run tech.dongdongbh.mindwtr "$@"
fi

# 3. Fallback a ejecutable mindwtr en PATH si existe y no es este script
REAL_MINDWTR=$(type -a -p mindwtr 2>/dev/null | grep -v "$HOME/.config/niri/scripts/launch-mindwtr.sh" | grep -v "$HOME/.local/bin/mindwtr" | head -n 1)
if [ -n "$REAL_MINDWTR" ] && [ -x "$REAL_MINDWTR" ]; then
    exec "$REAL_MINDWTR" "$@"
fi

echo "Error: No se encontró ningún AppImage, Flatpak ni ejecutable de Mindwtr." >&2
exit 1
