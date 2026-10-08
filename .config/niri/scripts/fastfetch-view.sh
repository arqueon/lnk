#!/usr/bin/env bash
# Visor interactivo y vistoso de Fastfetch para ventana flotante en Niri

# Título de terminal
printf "\033]0;%s\007" "System Fetch"

# Modo inicial: pokemon
mode="pokemon"

FORMATTER="$HOME/.local/bin/fastfetch-format"
if [[ ! -x "$FORMATTER" ]]; then
    FORMATTER="fastfetch"
fi

run_fetch() {
    clear
    case "$mode" in
        pokemon)
            if command -v pokemon-colorscripts >/dev/null 2>&1; then
                "$FORMATTER" --logo "pokemon-colorscripts -r --no-title" --logo-type command-raw
            else
                "$FORMATTER" --logo cachyos --logo-type builtin
            fi
            ;;
        cachy)
            "$FORMATTER" --logo cachyos --logo-type builtin
            ;;
        image)
            if [[ -f "$HOME/.config/fastfetch/logo_cachy.png" ]]; then
                "$FORMATTER" --logo "$HOME/.config/fastfetch/logo_cachy.png" --logo-type kitty --logo-width 38
            else
                "$FORMATTER" --logo cachyos --logo-type builtin
            fi
            ;;
    esac

    echo ""
    # Barra de atajos interactiva
    printf "\033[2m  \033[1;36m[r]\033[0;2m Reroll Pokémon  \033[0;2m│  \033[1;35m[c]\033[0;2m CachyOS ASCII  \033[0;2m│  \033[1;32m[i]\033[0;2m CachyOS Imagen  \033[0;2m│  \033[1;31m[q/Esc]\033[0;2m Salir\033[0m\n"
}

run_fetch

while true; do
    if ! read -rsn1 key; then
        break
    fi
    # Detección de tecla Escape (ESC)
    if [[ "$key" == $'\e' ]]; then
        read -rsn2 -t 0.05 rest
        if [[ -z "$rest" ]]; then
            break
        fi
    fi

    case "$key" in
        r|R|" ")
            mode="pokemon"
            run_fetch
            ;;
        c|C)
            mode="cachy"
            run_fetch
            ;;
        i|I)
            mode="image"
            run_fetch
            ;;
        q|Q|$'\n'|"")
            break
            ;;
    esac
done

clear 2>/dev/null || true
exit 0
