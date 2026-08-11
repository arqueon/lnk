#!/usr/bin/env bash
LNK_REPO="${LNK_HOME:-$HOME/.config/lnk}"
git -C "$LNK_REPO" fetch origin
git -C "$LNK_REPO" reset --hard origin/main
notify-send "lnk pull" "$(lnk pull)"

