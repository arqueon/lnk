"""Qtile de emergencia para abdel-lite.

Esta configuracion es deliberadamente pequena: usa la barra nativa de Qtile
y no depende de DMS, Waybar, Picom, Conky ni scripts de una distribucion.
"""

from pathlib import Path
import subprocess

from libqtile import bar, hook, layout, widget
from libqtile.backend.wayland import InputConfig
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy


mod = "mod4"
terminal = "kitty"
launcher = "fuzzel"


keys = [
    Key([mod], "Return", lazy.spawn(terminal), desc="Terminal"),
    Key([mod], "d", lazy.spawn(launcher), desc="Lanzador"),
    Key([mod], "e", lazy.spawn("thunar"), desc="Archivos"),
    Key([mod], "b", lazy.spawn("google-chrome-stable"), desc="Navegador"),
    Key([mod], "h", lazy.layout.left(), desc="Foco a la izquierda"),
    Key([mod], "l", lazy.layout.right(), desc="Foco a la derecha"),
    Key([mod], "j", lazy.layout.down(), desc="Foco abajo"),
    Key([mod], "k", lazy.layout.up(), desc="Foco arriba"),
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Mover a la izquierda"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Mover a la derecha"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Mover abajo"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Mover arriba"),
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Crecer a la izquierda"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Crecer a la derecha"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Crecer abajo"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Crecer arriba"),
    Key([mod], "n", lazy.layout.normalize(), desc="Normalizar ventanas"),
    Key([mod], "space", lazy.next_layout(), desc="Cambiar disposicion"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Pantalla completa"),
    Key([mod, "shift"], "space", lazy.window.toggle_floating(), desc="Ventana flotante"),
    Key([mod], "q", lazy.window.kill(), desc="Cerrar ventana"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Recargar Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Salir de Qtile"),
    Key(
        [mod],
        "Escape",
        lazy.spawn("swaylock -f -c 111318"),
        desc="Bloquear pantalla",
    ),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")),
    Key([], "XF86AudioMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")),
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next")),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous")),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +5%")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 5%-")),
    Key(
        [],
        "Print",
        lazy.spawn(
            "sh -lc 'mkdir -p \"$HOME/Pictures\"; "
            "grim -g \"$(slurp)\" \"$HOME/Pictures/Screenshot-$(date +%F-%H%M%S).png\"'"
        ),
        desc="Captura de region",
    ),
]


groups = [Group(str(number)) for number in range(1, 6)]

for group in groups:
    keys.extend(
        [
            Key([mod], group.name, lazy.group[group.name].toscreen()),
            Key([mod, "shift"], group.name, lazy.window.togroup(group.name)),
        ]
    )


layouts = [
    layout.Columns(
        border_focus="#d97757",
        border_normal="#2b3141",
        border_width=2,
        margin=6,
    ),
    layout.Max(),
]


widget_defaults = dict(font="Noto Sans", fontsize=13, padding=5)
extension_defaults = widget_defaults.copy()


screens = [
    Screen(
        top=bar.Bar(
            [
                widget.TextBox(text=" Qtile ", foreground="#f2cc8f"),
                widget.GroupBox(
                    active="#e7e9ee",
                    inactive="#77819a",
                    highlight_color="#30384a",
                    highlight_method="block",
                    this_current_screen_border="#d97757",
                    urgent_border="#e63946",
                ),
                widget.WindowName(foreground="#e7e9ee", max_chars=80),
                widget.CPU(format="CPU {load_percent:.0f}%", update_interval=5),
                widget.Memory(format="RAM {MemPercent:.0f}%", update_interval=5),
                widget.Battery(
                    format="{char} {percent:2.0%}",
                    charge_char="+",
                    discharge_char="-",
                    full_char="=",
                    unknown_char="?",
                    update_interval=15,
                ),
                widget.Clock(format="%a %d %b  %H:%M"),
            ],
            32,
            background="#171a21",
            border_color="#30384a",
            border_width=[0, 0, 1, 0],
            margin=[0, 0, 0, 0],
        )
    )
]


mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]


floating_layout = layout.Floating(
    border_focus="#d97757",
    border_normal="#2b3141",
    border_width=2,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
    ],
)


wl_input_rules = {
    "type:keyboard": InputConfig(
        kb_layout="us",
        kb_variant="intl",
        kb_options="ctrl:nocaps",
        kb_repeat_delay=300,
        kb_repeat_rate=25,
    ),
    "type:touchpad": InputConfig(
        tap=True,
        dwt=True,
        natural_scroll=False,
        pointer_accel=0.2,
    ),
}


@hook.subscribe.startup_once
def start_session_helpers():
    script = Path.home() / ".config/qtile/scripts/autostart.sh"
    if script.is_file():
        subprocess.Popen([str(script)])


dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wl_xcursor_theme = None
wl_xcursor_size = 24
wmname = "Qtile"
