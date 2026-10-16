#!/usr/bin/env bash
# Menú de apps de Google por cuenta para Niri (Abdel / abdel-home).
# Soporta modo submenú (Cuenta -> App) y modo plano/búsqueda global (--flat).

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

# Apps de Google disponibles (incluye Gemini)
apps=(
    'Drive|󰉋|https://drive.google.com/'
    'Gmail|󰇮|https://mail.google.com/mail/'
    'Calendar|󰃭|https://calendar.google.com/'
    'Classroom|󰑴|https://classroom.google.com/'
    'Keep|󰌵|https://keep.google.com/'
    'Cloud Console|󰅟|https://console.cloud.google.com/'
    'Gemini|󰚩|https://gemini.google.com/'
)

launch_url() {
    local target_url="$1"
    local target_profile="${2:-Default}"
    local selected_label="${3:-}"

    if [[ -n "${GOOGLE_APPS_DRYRUN:-}" ]]; then
        printf 'PROFILE=%s\nURL=%s\nSELECTED=%s\n' "$target_profile" "$target_url" "$selected_label"
        exit 0
    fi

    if [[ -x "$HOME/.config/niri/scripts/run_chrome.sh" ]]; then
        exec "$HOME/.config/niri/scripts/run_chrome.sh" --profile-directory="$target_profile" --app="$target_url"
    elif [[ -x "$script_dir/run_chrome.sh" ]]; then
        exec "$script_dir/run_chrome.sh" --profile-directory="$target_profile" --app="$target_url"
    else
        exec google-chrome-stable --no-default-browser-check --new-window --profile-directory="$target_profile" --app="$target_url"
    fi
}

# Construir items planos (retrocompatibilidad, búsqueda global y GOOGLE_APPS_PICK)
declare -A flat_urls
declare -A flat_profiles
flat_items=()
for account in "${accounts[@]}"; do
    IFS='|' read -r account_name email prof <<< "$account"
    prof="${prof:-Default}"
    for app in "${apps[@]}"; do
        IFS='|' read -r app_name icon base_url <<< "$app"
        item="$(printf '%s   %-18.18s │ %-12.12s │ %s' "$icon" "$app_name" "$account_name" "$email")"
        flat_items+=("$item")
        flat_urls["$item"]="${base_url}?authuser=${email//@/%40}"
        flat_profiles["$item"]="$prof"
    done
done

# Compatibilidad con GOOGLE_APPS_PICK
if [[ -n "${GOOGLE_APPS_PICK:-}" ]]; then
    selected="$(printf '%s\n' "${flat_items[@]}" | grep -E -i -m1 -- "$GOOGLE_APPS_PICK" || true)"
    [[ -n "$selected" ]] || exit 1
    target_url="${flat_urls[$selected]:-}"
    target_prof="${flat_profiles[$selected]:-Default}"
    [[ -n "$target_url" ]] || exit 1
    launch_url "$target_url" "$target_prof" "$selected"
fi

run_flat_menu() {
    local selected
    selected="$(printf '%s\n' "${flat_items[@]}" | fuzzel \
        --dmenu \
        --font='Cascadia Code NF:size=11' \
        --prompt='󰊭 Google (Todas) ❯ ' \
        --placeholder='Buscar app o cuenta de Google...' \
        --width=120 \
        --lines=16 \
        --line-height=26 \
        --horizontal-pad=20 \
        --vertical-pad=12 \
        --match-mode=fzf 2>/dev/null || true)"

    [[ -n "$selected" ]] || return 1
    local target_url="${flat_urls[$selected]:-}"
    local target_prof="${flat_profiles[$selected]:-Default}"
    [[ -n "$target_url" ]] || return 1
    launch_url "$target_url" "$target_prof" "$selected"
}

if [[ "${1:-}" == "--flat" ]]; then
    run_flat_menu || exit 0
    exit 0
fi

while true; do
    # Nivel 1: Selección de Cuenta
    account_menu=()
    declare -A account_emails
    declare -A account_names
    declare -A account_profs

    for account in "${accounts[@]}"; do
        IFS='|' read -r account_name email prof <<< "$account"
        prof="${prof:-Default}"
        opt="$(printf '󰊭   %-18.18s │ %s' "$account_name" "$email")"
        account_menu+=("$opt")
        account_emails["$opt"]="$email"
        account_names["$opt"]="$account_name"
        account_profs["$opt"]="$prof"
    done
    opt_all="󰍉   Todas las apps     │ Búsqueda global en todas las cuentas"
    account_menu+=("$opt_all")

    chosen_account="$(printf '%s\n' "${account_menu[@]}" | fuzzel \
        --dmenu \
        --font='Cascadia Code NF:size=11' \
        --prompt='󰊭 Google ❯ Cuenta: ' \
        --placeholder='Seleccionar cuenta de Google...' \
        --width=90 \
        --lines=10 \
        --line-height=26 \
        --horizontal-pad=20 \
        --vertical-pad=12 \
        --match-mode=fzf 2>/dev/null || true)"

    [[ -n "$chosen_account" ]] || exit 0

    if [[ "$chosen_account" == "$opt_all" ]]; then
        if run_flat_menu; then
            exit 0
        else
            continue
        fi
    fi

    sel_email="${account_emails[$chosen_account]:-}"
    sel_name="${account_names[$chosen_account]:-}"
    sel_prof="${account_profs[$chosen_account]:-Default}"
    [[ -n "$sel_email" ]] || exit 0

    # Nivel 2: Selección de App para la cuenta elegida
    app_menu=()
    declare -A app_urls

    for app in "${apps[@]}"; do
        IFS='|' read -r app_name icon base_url <<< "$app"
        app_opt="$(printf '%s   %-18.18s │ %s' "$icon" "$app_name" "$sel_email")"
        app_menu+=("$app_opt")
        app_urls["$app_opt"]="${base_url}?authuser=${sel_email//@/%40}"
    done
    opt_back="󰌍   « Volver a cuentas │ Cambiar de cuenta de Google"
    app_menu+=("$opt_back")

    chosen_app="$(printf '%s\n' "${app_menu[@]}" | fuzzel \
        --dmenu \
        --font='Cascadia Code NF:size=11' \
        --prompt="󰊭 ${sel_name} ❯ " \
        --placeholder="Seleccionar app para ${sel_email}..." \
        --width=95 \
        --lines=9 \
        --line-height=26 \
        --horizontal-pad=20 \
        --vertical-pad=12 \
        --match-mode=fzf 2>/dev/null || true)"

    # Si se pulsa Escape en el submenú o se elige Volver, regresa al nivel 1
    if [[ -z "$chosen_app" || "$chosen_app" == "$opt_back" ]]; then
        continue
    fi

    target_url="${app_urls[$chosen_app]:-}"
    [[ -n "$target_url" ]] || exit 1
    launch_url "$target_url" "$sel_prof" "$chosen_app"
done
