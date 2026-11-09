# Retiro de SmallDocs (2026-11-08)

SmallDocs (licencia Elastic-2.0; su bridge caducaba y perdía envíos) se sustituye por Plannotator para las decisiones y los VoBo, y por Quarto para los entregables pulidos.

- `aplicar.sh [ruben|abdel]`: retira el CLI, el servicio, los lanzadores, las skills, la asociación de `.md` y las rutas del shell. Los documentos de `~/.sdocs` se conservan. Después cambia el bloque SmallDocs de CLAUDE.md, AGENTS.md (Codex y OpenCode) y GEMINI.md por el protocolo Plannotator.
- Ya aplicado: casa, oficina, abdel-home, hermes y sinope (sinope@sinope).
- Pendiente: ruben-laptop y star-lite. Estaban apagados; correr `bash aplicar.sh` cuando enciendan.
- Los AGENTS.md por equipo del repo ya traen el protocolo nuevo.
