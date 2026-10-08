#!/usr/bin/env bash
# Visor interactivo y vistoso de Fastfetch para ventana flotante en Niri

# Título de terminal
printf "\033]0;%s\007" "System Fetch"

# Modo inicial: cachy (ASCII chico estilizado)
mode="cachy"

FORMATTER="$HOME/.local/bin/fastfetch-format"
if [[ ! -x "$FORMATTER" ]]; then
    FORMATTER="fastfetch"
fi

LOGO_IMG="$HOME/.config/fastfetch/logo_cachy.png"
LOGO_CACHE="/tmp/fastfetch_cachy_logo.txt"

ensure_chafa_logo() {
    if [[ ! -f "$LOGO_CACHE" && -f "$LOGO_IMG" ]] && command -v chafa >/dev/null 2>&1; then
        python3 -c '
import subprocess, re, wcwidth, os

img = os.path.expanduser("~/.config/fastfetch/logo_cachy.png")
target_w = 32
target_h = 16
top_pad = 5

try:
    raw = subprocess.check_output([
        "chafa", "-f", "symbols", "--symbols=vhalf+quad+block",
        img, f"--size={target_w}x{target_h}"
    ], text=True)

    ansi_strip = re.compile(r"\x1b(?:\[[0-9;?]*[ -/]*[@-~]|\][^\x07\x1b]*(?:\x07|\x1b\\)|_[^\x1b]*(?:\x1b\\|\x07)|[@-Z\\-_])")
    cursor_moves = re.compile(r"\x1b\[\?[0-9]+[hl]")

    lines = [" " * target_w for _ in range(top_pad)]
    for line in raw.splitlines():
        line = cursor_moves.sub("", line)
        clean = ansi_strip.sub("", line)
        w = max(0, wcwidth.wcswidth(clean))
        if w < target_w:
            line += " " * (target_w - w)
        lines.append(line)

    with open("/tmp/fastfetch_cachy_logo.txt", "w") as f:
        f.write("\n".join(lines) + "\n")
except Exception:
    pass
' 2>/dev/null
    fi
}

run_fetch() {
    clear
    case "$mode" in
        cachy)
            # Logo ASCII chico (~24 columnas, diseño compacto y elegante)
            "$FORMATTER" --logo cachyos --logo-type small
            ;;
        cachy_big)
            # Logo ASCII grande tradicional
            "$FORMATTER" --logo cachyos --logo-type builtin
            ;;
        pokemon)
            if command -v pokemon-colorscripts >/dev/null 2>&1; then
                "$FORMATTER" --logo "pokemon-colorscripts -r --no-title" --logo-type command-raw
            else
                "$FORMATTER" --logo cachyos --logo-type small
            fi
            ;;
        image)
            ensure_chafa_logo
            if [[ -f "$LOGO_CACHE" ]]; then
                "$FORMATTER" --file-raw "$LOGO_CACHE"
            elif [[ -f "$LOGO_IMG" ]]; then
                "$FORMATTER" --logo "$LOGO_IMG" --logo-type kitty --logo-width 36
            else
                "$FORMATTER" --logo cachyos --logo-type small
            fi
            ;;
    esac

    echo ""
    # Barra de atajos interactiva
    printf "\033[2m  \033[1;35m[c]\033[0;2m Cachy Chico  \033[0;2m│  \033[1;32m[i]\033[0;2m Cachy Gráfico  \033[0;2m│  \033[1;36m[r]\033[0;2m Pokémon  \033[0;2m│  \033[1;33m[C]\033[0;2m ASCII Grande  \033[0;2m│  \033[1;31m[q/Esc]\033[0;2m Salir\033[0m\n"
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
        c)
            mode="cachy"
            run_fetch
            ;;
        C)
            mode="cachy_big"
            run_fetch
            ;;
        i|I)
            mode="image"
            run_fetch
            ;;
        r|R|" ")
            mode="pokemon"
            run_fetch
            ;;
        q|Q|$'\n'|"")
            break
            ;;
    esac
done

clear 2>/dev/null || true
exit 0
