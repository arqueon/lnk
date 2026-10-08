#!/usr/bin/env bash
set -euo pipefail

# Desbloqueo privado del broker Moodle de Hermes. La consulta no arranca nada.
REMOTE_CMD="/home/hermes/.local/bin/hermes-bw-moodle-broker-start"
restart=false
interactive=false
status_only=false
for arg in "$@"; do
    case "$arg" in
        --restart|-r) restart=true ;;
        --interactive) interactive=true ;;
        --status) status_only=true ;;
        *) printf 'Uso: %s [--restart|-r|--status]\n' "$0" >&2; exit 2 ;;
    esac
done
if $restart && $status_only; then
    printf 'No se pueden combinar --restart y --status.\n' >&2
    exit 2
fi

notify() {
    notify-send -i "$1" -u normal "Hermes Broker Moodle" "$2" 2>/dev/null || true
}

check_status() {
    # ConnectTimeout no limita la duración del comando remoto.
    timeout 145s ssh -n -T -o BatchMode=yes -o ConnectTimeout=4 \
        -o ServerAliveInterval=10 -o ServerAliveCountMax=2 \
        hermes@sinope "$REMOTE_CMD" --status
}

if $status_only; then
    check_status
    exit 0
fi

# Kitty reentra con --interactive: no repetir la consulta ni perder --restart.
if ! $restart && ! $interactive; then
    if check_status; then
        notify security-high "El broker está activo y puede leer Bitwarden en Sinope."
        exit 0
    else
        rc=$?
        if [[ $rc -ne 3 ]]; then
            notify dialog-error "No se pudo verificar el broker (código $rc). Ejecuta el script con --status en una terminal para ver el diagnóstico."
            exit "$rc"
        fi
    fi
fi

if [[ ! -t 0 ]]; then
    if $interactive; then
        printf 'No se pudo abrir una terminal interactiva.\n' >&2
        exit 1
    fi
    args=(--interactive)
    if $restart; then args+=(--restart); fi
    exec kitty --class hermes-broker-unlock \
        --title "Desbloquear Broker Moodle Hermes" "$0" "${args[@]}"
fi

printf '\033[1;34m[Hermes Sinope]\033[0m Desbloqueo de Bitwarden Broker (Moodle)\n'
printf 'Conectando con Sinope. Introduce la contraseña maestra si se te solicita...\n\n'
remote_args=("$REMOTE_CMD")
if $restart; then remote_args+=(--restart); fi
rc=0
ssh -tt -o ConnectTimeout=10 -o ServerAliveInterval=10 -o ServerAliveCountMax=2 \
    hermes@sinope "${remote_args[@]}" || rc=$?
if [[ $rc -eq 0 ]]; then
    check_status || rc=$?
fi
if [[ $rc -eq 0 ]]; then
    notify security-high "Broker desbloqueado y acceso a Bitwarden verificado."
    printf '\n\033[1;32m✓ Broker listo.\033[0m Cerrando ventana...\n'
    sleep 1.2
else
    notify dialog-error "No se pudo desbloquear o verificar el broker (código $rc)."
    printf '\n\033[1;31m✗ Error al iniciar o verificar el broker (código %s).\033[0m\n' "$rc"
    printf 'Revisa el diagnóstico anterior y la conexión SSH.\n'
    read -r -n 1 -s -p 'Pulsa cualquier tecla para cerrar…' || true
    printf '\n'
fi
exit "$rc"
