#!/bin/bash

# Lanzar aplicaciones multimedia (Aurral, YouTube Music, Navidrome y Jellytoast)
~/.config/niri/scripts/run_chrome.sh --app="https://aurral.arqueonautis.org/" &
sleep 0.2
~/.config/niri/scripts/run_chrome.sh --app="https://music.youtube.com/" &
sleep 0.2
~/.config/niri/scripts/run_chrome.sh --app="https://navidrome.arqueonautis.org/app/" &
if command -v jellytoast >/dev/null 2>&1; then
    sleep 0.2
    beacon &
fi
