#!/usr/bin/env bash
# Menú de apps de Google por cuenta para Niri (Abdel / abdel-home).

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cuentas de Abdel en abdel-home asociadas a sus perfiles dedicados en Chrome
accounts=(
    'abdeluck|abdeluck@gmail.com|Default'
    'cgpe.udg.mx|abdel@cgpe.udg.mx|Profile 7'
    'Barbies|barbiestesteadoras@gmail.com|Profile 8'
    'El Recreo|el.recreo.labhouse@gmail.com|Profile 4'
    'GoFlow!|hola.goflow@gmail.com|Profile 2'
    'Oleicos|oleicoscannabicos@gmail.com|Profile 3'
    'Simposio|cuerpoyerotismogdl@gmail.com|Profile 6'
)

# Apps de Google disponibles (incluye Google Keep)
apps=(
    'Drive|󰉋|https://drive.google.com/'
    'Gmail|󰇮|https://mail.google.com/mail/'
    'Calendar|󰃭|https://calendar.google.com/'
    'Classroom|󰑴|https://classroom.google.com/'
    'Keep|󰌵|https://keep.google.com/'
    'Cloud Console|󰅟|https://console.cloud.google.com/'
)

declare -A urls
declare -A profiles
items=()
for account in "${accounts[@]}"; do
    IFS='|' read -r account_name email prof <<< "$account"
    prof="${prof:-Default}"
    for app in "${apps[@]}"; do
        IFS='|' read -r app_name icon base_url <<< "$app"
        item="$(printf '%s   %-18.18s │ %-12.12s │ %s' "$icon" "$app_name" "$account_name" "$email")"
        items+=("$item")
        urls["$item"]="${base_url}?authuser=${email//@/%40}"
        profiles["$item"]="$prof"
    done
done

if [[ -n "${GOOGLE_APPS_PICK:-}" ]]; then
    selected="$(printf '%s\n' "${items[@]}" | grep -F -m1 -- "$GOOGLE_APPS_PICK" || true)"
else
    selected="$(printf '%s\n' "${items[@]}" | fuzzel \
        --dmenu \
        --font='Cascadia Code NF:size=11' \
        --prompt='󰊭 Google ❯ ' \
        --placeholder='Buscar app o cuenta de Google...' \
        --width=120 \
        --lines=16 \
        --line-height=26 \
        --horizontal-pad=20 \
        --vertical-pad=12 \
        --match-mode=fzf 2>/dev/null || true)"
fi

[[ -n "$selected" ]] || exit 0
target_url="${urls[$selected]:-}"
target_profile="${profiles[$selected]:-Default}"
[[ -n "$target_url" ]] || exit 1

if [[ -n "${GOOGLE_APPS_DRYRUN:-}" ]]; then
    printf 'PROFILE=%s\nURL=%s\nSELECTED=%s\n' "$target_profile" "$target_url" "$selected"
    exit 0
fi

if [[ -x "$HOME/.config/niri/scripts/run_chrome.sh" ]]; then
    exec "$HOME/.config/niri/scripts/run_chrome.sh" --profile-directory="$target_profile" --app="$target_url"
elif [[ -x "$script_dir/run_chrome.sh" ]]; then
    exec "$script_dir/run_chrome.sh" --profile-directory="$target_profile" --app="$target_url"
else
    exec google-chrome-stable --no-default-browser-check --new-window --profile-directory="$target_profile" --app="$target_url"
fi
