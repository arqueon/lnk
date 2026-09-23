#!/usr/bin/env bash
# Menú de apps de Google por cuenta para Niri (ofi).

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# El correo selecciona la sesión de Google sin depender de /u/0, /u/1, etc.
accounts=(
    'UdeG|ruben.garcia.sanchez@udg.mx'
    'Personal|arqueonautis@gmail.com'
    'Academicos|ruben.gsanchez@academicos.udg.mx'
)
apps=(
    'Drive|󰉋|https://drive.google.com/'
    'Gmail|󰇮|https://mail.google.com/mail/'
    'Calendar|󰃭|https://calendar.google.com/'
    'Classroom|󰑴|https://classroom.google.com/'
    'Cloud Console|󰅟|https://console.cloud.google.com/'
)

declare -A urls
items=()
for account in "${accounts[@]}"; do
    IFS='|' read -r account_name email <<< "$account"
    for app in "${apps[@]}"; do
        IFS='|' read -r app_name icon base_url <<< "$app"
        item="$(printf '%s   %-18.18s │ %-12.12s │ %s' "$icon" "$app_name" "$account_name" "$email")"
        items+=("$item")
        urls["$item"]="${base_url}?authuser=${email//@/%40}"
    done
done

selected="$(printf '%s\n' "${items[@]}" | fuzzel \
    --dmenu \
    --font='Cascadia Code NF:size=11' \
    --prompt='󰊭 Google ❯ ' \
    --placeholder='Buscar app o cuenta de Google...' \
    --width=120 \
    --lines=15 \
    --line-height=26 \
    --horizontal-pad=20 \
    --vertical-pad=12 \
    --match-mode=fzf 2>/dev/null || true)"

[[ -n "$selected" ]] || exit 0
target_url="${urls[$selected]:-}"
[[ -n "$target_url" ]] || exit 1

exec "$script_dir/run_chrome.sh" --profile-directory=Default --app="$target_url"
