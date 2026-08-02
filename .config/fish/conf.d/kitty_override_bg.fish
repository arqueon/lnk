# Preservar color de fondo personalizado en terminales Kitty específicas (matriz hex)
if test -n "$KITTY_HEX_BG"
    printf "\033]11;%s\007" "$KITTY_HEX_BG"
    function __preserve_kitty_hex_bg --on-event fish_prompt
        if test -n "$KITTY_HEX_BG"
            printf "\033]11;%s\007" "$KITTY_HEX_BG"
        end
    end
end
