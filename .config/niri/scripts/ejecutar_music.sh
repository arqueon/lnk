#!/bin/bash

# Lanzar aplicaciones multimedia (Aurral, YouTube Music y Aonsoku)
~/.config/niri/scripts/run_chrome.sh --app="https://aurral.arqueonautis.org/" &
sleep 0.2
~/.config/niri/scripts/run_chrome.sh --app="https://music.youtube.com/" &
sleep 0.2
/opt/Aonsoku/aonsoku &

