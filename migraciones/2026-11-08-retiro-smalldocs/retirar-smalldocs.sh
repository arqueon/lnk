#!/usr/bin/env bash
# Retira SmallDocs (programa e integración) sin borrar los documentos de ~/.sdocs.
set -u
echo "== $(hostname) / $(whoami)"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# 1. Servicio y procesos del CLI
systemctl --user disable --now sdoc-library.service 2>/dev/null && echo "servicio sdoc-library detenido"
for pid in $(pgrep -u "$(id -u)" -f 'sdocs-dev\.js|\.sdocs/cli/bin' 2>/dev/null); do kill "$pid" 2>/dev/null && echo "proceso $pid terminado"; done

# 2. Enlaces y lanzadores (symlinks de lnk o archivos sueltos)
for f in ~/.config/systemd/user/sdoc-library.service ~/.local/bin/md ~/.local/bin/sdoc ~/.local/bin/sdoc-embed-images ~/.local/bin/sdoc-open \
         ~/.local/share/applications/sdoc.desktop ~/.config/niri/scripts/sdoc-open.sh ~/.config/niri/scripts/launch-sdoc-library.sh ~/.sdocsignore; do
  if [ -L "$f" ] || [ -f "$f" ]; then rm -f "$f" && echo "quitado $f"; fi
done
systemctl --user daemon-reload 2>/dev/null

# 3. El programa (los documentos se conservan)
if [ -d ~/.sdocs ]; then
  rm -rf ~/.sdocs/cli ~/.sdocs/bin ~/.sdocs/library-index.json ~/.sdocs/library-state.json ~/.sdocs/update-check.json ~/.sdocs/setup.json
  [ -L ~/.sdocs/styles.yaml ] && rm -f ~/.sdocs/styles.yaml
  printf 'SmallDocs se retiró el 2026-11-08 (licencia Elastic-2.0; bridge poco fiable).\nEstos documentos se conservan como archivo; ya no se crean nuevos.\nDecisiones y VoBo: archivos .revision/*.md abiertos con plannotator.\n' > ~/.sdocs/RETIRADO.txt
  echo "CLI de ~/.sdocs eliminado; documentos conservados ($(du -sh ~/.sdocs | cut -f1))"
fi

# 4. Skills de agentes
for d in ~/.claude/skills/smalldocs ~/.agents/skills/smalldocs ~/.codex/skills/smalldocs ~/.gemini/skills/smalldocs ~/.hermes/skills/smalldocs; do
  if [ -L "$d" ] || [ -e "$d" ]; then rm -rf "$d" && echo "skill quitada $d"; fi
done

# 5. Asociación de archivos .md
m=~/.config/mimeapps.list
if [ -f "$m" ] && [ ! -L "$m" ] && grep -q 'sdoc.desktop' "$m"; then
  cp -p "$m" "$m.bak-smalldocs-2026-11-08"
  sed -i -E 's/([=;])sdoc\.desktop;?/\1/g; /^[^=[]+=$/d' "$m"
  echo "mimeapps.list sin sdoc.desktop"
fi
command -v update-desktop-database >/dev/null && update-desktop-database ~/.local/share/applications 2>/dev/null

# 6. Shell rc no gestionados por lnk
for rc in ~/.bashrc ~/.zshrc ~/.config/fish/config.fish ~/.profile; do
  [ -f "$rc" ] && [ ! -L "$rc" ] || continue
  if grep -q -E 'sdoc|\.sdocs/bin' "$rc"; then
    cp -p "$rc" "$rc.bak-smalldocs-2026-11-08"
    sed -i -E '/alias md=.?sdoc/d; /# added by the sdoc installer/d; /\.sdocs\/bin/d' "$rc"
    echo "limpiado $rc"
  fi
done

# 7. Comprobación
echo "-- restos:"
systemctl --user is-active sdoc-library.service 2>/dev/null | sed 's/^/servicio: /'
command -v sdoc md 2>/dev/null | sed 's/^/en PATH: /'
find ~/.local ~/.config -maxdepth 4 -xtype l -name '*sdoc*' 2>/dev/null | sed 's/^/symlink roto: /'
grep -l -E 'alias md=.?sdoc|\.sdocs/bin' ~/.bashrc ~/.zshrc ~/.config/fish/config.fish 2>/dev/null | sed 's/^/rc con restos: /'
echo "fin"
