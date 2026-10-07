#!/usr/bin/env bash
set -uo pipefail

# 1. Ubicar el repositorio
if [ -d "$HOME/Projects/zettlr/palestina-lo-intolerable" ]; then
    REPO_DIR="$HOME/Projects/zettlr/palestina-lo-intolerable"
elif [ -d "$HOME/Nextcloud/Projects/zettlr/palestina-lo-intolerable" ]; then
    REPO_DIR="$HOME/Nextcloud/Projects/zettlr/palestina-lo-intolerable"
elif [ -d "/media/hrdisk/Nextcloud/Projects/zettlr/palestina-lo-intolerable" ]; then
    REPO_DIR="/media/hrdisk/Nextcloud/Projects/zettlr/palestina-lo-intolerable"
else
    notify-send -u critical -a "Palestina" -i dialog-error "Error de sincronización" "No se encontró el repositorio de Palestina."
    exit 1
fi

cd "$REPO_DIR" || exit 1

notify-send -a "Palestina" -i document-save -t 2000 "Sincronizando Palestina..." "Guardando y sincronizando cambios..."

# 2. Hacer commit de cambios locales si los hay
LOCAL_COMMITTED=0
if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -m "avance: $(date +'%Y-%m-%d %H:%M')"
    LOCAL_COMMITTED=1
fi

# 3. Detectar entorno y configurar peer
PULLED=0
PUSHED=0
CONFLICT=0
PEER_UNREACHABLE=0

if git remote | grep -q "^abdel$"; then
    REMOTE_PEER="abdel"
    PEER_NAME="abdel-home"
elif git remote | grep -q "^origin$" && git remote get-url origin | grep -q "casa-cachyos"; then
    REMOTE_PEER="origin"
    PEER_NAME="casa-cachyos"
else
    REMOTE_PEER="origin"
    PEER_NAME="remoto"
fi

# Sincronización con el peer directo (Tailscale SSH)
if git fetch "$REMOTE_PEER" main 2>/dev/null; then
    BEHIND=$(git rev-list --count HEAD.."${REMOTE_PEER}"/main)
    if [ "$BEHIND" -gt 0 ]; then
        if git pull --rebase "$REMOTE_PEER" main; then
            PULLED=$BEHIND
        else
            CONFLICT=1
        fi
    fi

    AHEAD=$(git rev-list --count "${REMOTE_PEER}"/main..HEAD)
    if [ "$AHEAD" -gt 0 ] && [ "$CONFLICT" -eq 0 ]; then
        if git push "$REMOTE_PEER" main; then
            PUSHED=$AHEAD
        fi
    fi
else
    PEER_UNREACHABLE=1
fi

# Respaldo secundario hacia GitHub si está configurado
if git remote | grep -q "^github$"; then
    git push github main 2>/dev/null || true
elif git remote | grep -q "^origin$" && git remote get-url origin | grep -q "github\.com"; then
    git push origin main 2>/dev/null || true
fi

# 4. Notificaciones
if [ "$CONFLICT" -eq 1 ]; then
    notify-send -u critical -a "Palestina" -i dialog-warning "⚠️ Conflicto en Git" "Hay cambios simultáneos en las mismas líneas. Revisa el archivo en Zettlr o terminal."
elif [ "$PULLED" -gt 0 ] || [ "$PUSHED" -gt 0 ] || [ "$LOCAL_COMMITTED" -eq 1 ]; then
    MSG="Sincronizado con $PEER_NAME."
    [ "$LOCAL_COMMITTED" -eq 1 ] && MSG="$MSG Guardado local."
    [ "$PULLED" -gt 0 ] && MSG="$MSG Recibidos $PULLED cambios."
    [ "$PUSHED" -gt 0 ] && MSG="$MSG Enviados $PUSHED cambios."
    notify-send -a "Palestina" -i emblem-default -t 3500 "✅ Palestina sincronizado" "$MSG"
elif [ "$PEER_UNREACHABLE" -eq 1 ]; then
    notify-send -u normal -a "Palestina" -i network-offline -t 3500 "⚠️ Guardado local" "Sin conexión directa con $PEER_NAME. Los avances se guardaron localmente."
else
    notify-send -a "Palestina" -i emblem-default -t 2000 "✅ Palestina al día" "Todo sincronizado con $PEER_NAME. Sin cambios pendientes."
fi
