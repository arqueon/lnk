#!/bin/bash

tmpfile=$(mktemp)
grim -g "$(slurp)" - >"$tmpfile" && notify_view "satty"
satty -f - <"$tmpfile"
rm "$tmpfile"

