#!/usr/bin/env bash
set -euo pipefail

# hermes-bw-moodle-unlock.sh
# Desbloquea / inicia el broker de Bitwarden para Moodle en Sinope (hermes@sinope).
# Si ya está activo, notifica y termina de inmediato sin abrir terminales.
# Si está bloqueado o requiere contraseña, lanza una ventana flotante de Kitty.

REMOTE_CMD="/home/hermes/.local/bin/hermes-bw-moodle-broker-start"
RESTART_FLAG="${1:-}"

# 1. Comprobación rápida en segundo plano (si no se solicitó reinicio forzado)
if [[ "${RESTART_FLAG}" != "--restart" && "${RESTART_FLAG}" != "-r" ]]; then
    if status="$(ssh -o BatchMode=yes -o ConnectTimeout=4 hermes@sinope "${REMOTE_CMD}" 2>&1)"; then
        if [[ "${status}" =~ "BW_BROKER_ALREADY_READY" ]]; then
            notify-send -i security-high -u normal "Hermes Broker Moodle" "El broker ya está activo y desbloqueado en Sinope."
            exit 0
        fi
    fi
fi

# 2. Si no estamos en un TTY interactivo, lanzar ventana flotante dedicada de Kitty
if [[ ! -t 0 ]]; then
    exec kitty --class hermes-broker-unlock \
               --title "Desbloquear Broker Moodle Hermes" \
               "$0" --interactive "${RESTART_FLAG}"
fi

# 3. Flujo interactivo dentro del TTY
printf "\033[1;34m[Hermes Sinope]\033[0m Desbloqueo de Bitwarden Broker (Moodle)\n"
printf "Conectando con Sinope. Introduce la contraseña maestra si se te solicita...\n\n"

remote_args=("${REMOTE_CMD}")
if [[ "${2:-}" == "--restart" || "${2:-}" == "-r" ]]; then
    remote_args+=("--restart")
fi

set +e
ssh -tt hermes@sinope "${remote_args[@]}"
rc=$?
set -e

if [[ $rc -eq 0 ]]; then
    notify-send -i security-high -u normal "Hermes Broker Moodle" "Broker desbloqueado e iniciado correctamente."
    printf "\n\033[1;32m✓ Broker listo.\033[0m Cerrando ventana...\n"
    sleep 1.2
    exit 0
else
    printf "\n\033[1;31m✗ Error al iniciar o desbloquear el broker (código %s).\033[0m\n" "$rc"
    printf "Revisa la contraseña maestra o la conexión SSH.\n"
    read -r -n 1 -s -p "Pulsa cualquier tecla para cerrar…"
    printf "\n"
    exit $rc
fi
