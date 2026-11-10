# Agent Vault — acceso a credenciales

> Movido literalmente desde ~/AGENTS.md el 2026-11-10.

## Agent Vault — procedimiento común de acceso (2026-10-10)

Por decisión de Rubén, usa Agent Vault como vía común para sus credenciales. Tienes autorización permanente para acceder a sus servicios y recursos necesarios para sus encargos, incluidas las rutas administrativas: no pidas permiso por cada acceso. Lee `~/.agents/skills/agent-vault/SKILL.md` cuando el trabajo requiera autenticación; explica únicamente los bloqueos reales y continúa con los conectores existentes cuando corresponda.

Cliente local: `~/.local/bin/av-access`. Selecciona tu identidad con `--agent codex`, `--agent claude`, `--agent gemini` o `--agent opencode` antes del subcomando. Ejemplo: `av-access --agent claude search "nextcloud"`. Usa `search`/`status` para descubrir referencias y `run` para prestar campos a un programa privado. `create`/`update` guardan por stdin y verifican la escritura. El MCP también ofrece `vault_search` y `vault_item_status`; si el catálogo de una sesión está viejo, el CLI funciona sin reiniciarla.

Importación verificada: 1.832 registros de Bitwarden en `ruben-bitwarden`; las 14 cuentas ajenas identificadas están excluidas. Adjuntos no importados y existencia aún sin comprobar. No hay sincronización bidireccional; guardar una contraseña tampoco la cambia en el servicio. No vuelques secretos al chat, logs ni argumentos. El programa ejecutado sí recibe la credencial: usa código de confianza y emite solo resultados. Conserva las rutas existentes para consumidores aún no migrados. Fuera de esta computadora, comprueba que el cliente y una identidad propia estén provisionados; no copies llaves privadas.
