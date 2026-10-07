#!/usr/bin/env bash
set -uo pipefail

# 1. Ubicar el repositorio de trabajo
if [ -d "$HOME/Projects/zettlr/palestina-lo-intolerable" ]; then
    REPO_DIR="$HOME/Projects/zettlr/palestina-lo-intolerable"
elif [ -d "$HOME/Nextcloud/Projects/zettlr/palestina-lo-intolerable" ]; then
    REPO_DIR="$HOME/Nextcloud/Projects/zettlr/palestina-lo-intolerable"
elif [ -d "/media/hrdisk/Nextcloud/Projects/zettlr/palestina-lo-intolerable" ]; then
    REPO_DIR="/media/hrdisk/Nextcloud/Projects/zettlr/palestina-lo-intolerable"
else
    notify-send -u critical -a "Palestina" -i dialog-error "Error de sincronización" "No se encontró el repositorio de Palestina en este equipo."
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

# 3. Detectar y sincronizar remotes
PULLED=0
PUSHED=0
CONFLICT=0
SYNCED_PEERS=()
FAILED_PEERS=()

# Remotes de pares directos (Tailscale SSH)
REMOTES_TO_SYNC=()

if git remote | grep -q "^abdel$"; then
    REMOTES_TO_SYNC+=("abdel")
fi

if git remote | grep -q "^casa$"; then
    REMOTES_TO_SYNC+=("casa")
fi

if git remote | grep -q "^ofi$"; then
    REMOTES_TO_SYNC+=("ofi")
fi

# Si origin apunta a una máquina de la red (p. ej. casa-cachyos desde abdel-home)
if git remote | grep -q "^origin$" && git remote get-url origin | grep -qE "casa-cachyos|abdel-home"; then
    REMOTES_TO_SYNC+=("origin")
fi

# Remote de GitHub
if git remote | grep -q "^github$"; then
    GITHUB_REMOTE="github"
elif git remote | grep -q "^origin$" && git remote get-url origin | grep -q "github\.com"; then
    GITHUB_REMOTE="origin"
else
    GITHUB_REMOTE=""
fi

# Si no hay pares directos pero existe GitHub, sincronizar GitHub como objetivo principal
if [ ${#REMOTES_TO_SYNC[@]} -eq 0 ] && [ -n "${GITHUB_REMOTE}" ]; then
    REMOTES_TO_SYNC+=("${GITHUB_REMOTE}")
fi

for r in "${REMOTES_TO_SYNC[@]}"; do
    if git fetch --timeout=5 "$r" main 2>/dev/null; then
        BEHIND=$(git rev-list --count HEAD.."${r}"/main 2>/dev/null || echo 0)
        if [ "$BEHIND" -gt 0 ]; then
            if git pull --rebase "$r" main; then
                PULLED=$((PULLED + BEHIND))
            else
                CONFLICT=1
                break
            fi
        fi

        AHEAD=$(git rev-list --count "${r}"/main..HEAD 2>/dev/null || echo 0)
        if [ "$AHEAD" -gt 0 ] && [ "$CONFLICT" -eq 0 ]; then
            if git push "$r" main; then
                PUSHED=$((PUSHED + AHEAD))
            fi
        fi
        SYNCED_PEERS+=("$r")
    else
        FAILED_PEERS+=("$r")
    fi
done

# Respaldo secundario hacia GitHub si hay cambios y no fue el único remoto sincronizado
if [ "$CONFLICT" -eq 0 ] && [ -n "$GITHUB_REMOTE" ]; then
    git push "$GITHUB_REMOTE" main 2>/dev/null || true
fi

# 4. Notificaciones de estado
if [ "$CONFLICT" -eq 1 ]; then
    notify-send -u critical -a "Palestina" -i dialog-warning "⚠️ Conflicto en Git" "Hay cambios simultáneos en las mismas líneas. Revisa el archivo en Zettlr o terminal."
elif [ "$PULLED" -gt 0 ] || [ "$PUSHED" -gt 0 ] || [ "$LOCAL_COMMITTED" -eq 1 ]; then
    PEER_LABEL="${SYNCED_PEERS[*]:-remoto}"
    MSG="Sincronizado con [$PEER_LABEL]."
    [ "$LOCAL_COMMITTED" -eq 1 ] && MSG="$MSG Guardado local."
    [ "$PULLED" -gt 0 ] && MSG="$MSG Recibidos $PULLED cambios."
    [ "$PUSHED" -gt 0 ] && MSG="$MSG Enviados $PUSHED cambios."
    notify-send -a "Palestina" -i emblem-default -t 3500 "✅ Palestina sincronizado" "$MSG"
elif [ ${#SYNCED_PEERS[@]} -eq 0 ] && [ ${#FAILED_PEERS[@]} -gt 0 ]; then
    notify-send -u normal -a "Palestina" -i network-offline -t 3500 "⚠️ Guardado local" "Sin conexión directa con [${FAILED_PEERS[*]}]. Los avances se guardaron localmente."
else
    PEER_LABEL="${SYNCED_PEERS[*]:-remoto}"
    notify-send -a "Palestina" -i emblem-default -t 2000 "✅ Palestina al día" "Todo sincronizado con [$PEER_LABEL]. Sin cambios pendientes."
fi
