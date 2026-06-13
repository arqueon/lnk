#!/usr/bin/env bash

killall waybar
pkill waybar
waybar -c ~/.config/niri/waybar/config.jsonc -s ~/.config/niri/waybar/style.css
