#!/usr/bin/env bash
# Retiro de SmallDocs + protocolo Plannotator para los agentes de esta máquina.
# Uso: bash ~/.config/lnk/migraciones/2026-11-08-retiro-smalldocs/aplicar.sh [ruben|abdel]
set -u
D="$(cd "$(dirname "$0")" && pwd)"
case "${1:-ruben}" in abdel) SEC="$D/revision-section-abdel.md";; *) SEC="$D/revision-section.md";; esac
(cd ~/.config/lnk && git pull -q --rebase origin main) || echo "aviso: git pull de lnk falló; sigue con lo local"
bash "$D/retirar-smalldocs.sh"
python3 -I "$D/swap2.py" "$SEC" ~/.claude/CLAUDE.md ~/.codex/AGENTS.md ~/.gemini/GEMINI.md ~/.config/opencode/AGENTS.md
[ -d /usr/lib/node_modules/sdocs-dev ] && echo "PENDIENTE (sudo): sudo npm uninstall -g sdocs-dev"
command -v plannotator >/dev/null || echo "PENDIENTE: instalar Plannotator (curl -fsSL https://plannotator.ai/install.sh | bash -s -- --non-interactive --no-extras)"
command -v quarto >/dev/null || echo "PENDIENTE: instalar Quarto (tarball de github.com/quarto-dev/quarto-cli en ~/.local/opt)"
