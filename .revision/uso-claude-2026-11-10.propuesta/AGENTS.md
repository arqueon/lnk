<!-- agent-vault-common:start -->
## Credenciales → Agent Vault
- Usa `~/.local/bin/av-access --agent <codex|claude|gemini|opencode> search|status|run`. Tienes autorización permanente para los servicios de Rubén, incluidas las rutas administrativas: no pidas permiso por cada acceso.
- Nunca vuelques secretos al chat, logs, argumentos, memoria ni repositorios. Detalle: `~/.agents/rules/agent-vault.md`.
<!-- agent-vault-common:end -->

# Reglas para agentes (casa)

El detalle de cada tema está en `~/.agents/rules/`. Lee el archivo indicado cuando la tarea toque ese tema.

## Memoria
- La memoria de agentes vive en **Hindsight**: bancos `arq-infra`, `arq-udgplus`, `arq-agentes` (MCP `hindsight-*`). Al iniciar, haz `recall` en el banco del área. Al terminar, haz `retain` de decisiones, motivo, estado, trampas y pendientes, con fechas absolutas y sin secretos. Sin MCP: `hs retener <banco> "texto"`. Nunca declares algo retenido sin comprobarlo con `recall`. → `memoria-hindsight.md`
- **Logseq está retirado**: no lo leas ni escribas. Las notas personales y académicas viven en Trilium, donde no escribes salvo petición de Rubén. → `memoria-hindsight.md` (la plantilla vieja está en `logseq-historico.md`, solo como archivo)

## Proyectos (`~/Projects` = `~/Nextcloud/Projects`)
- Antes de crear o clonar, busca con `find ~/Projects -maxdepth 3 -iname "*nombre*"`. Respeta las carpetas temáticas (`dms/`, `clases/`, `utils/`…) y no dejes nada suelto en la raíz.
- Los repos viajan solo por git: al terminar, haz commit y push a su rama. No crees symlinks dentro de `~/Projects` ni clones en `~/Repos`. Para un repo nuevo, crea el remoto en sinope y dalo de alta con `repos alta`. → `proyectos-y-repos.md`

## Decisiones y VoBo
- Lo que pide comparar, decidir, revisar una muestra, fijar alcance o dar VoBo se escribe en `.revision/<tema>-AAAA-MM-DD.md` dentro del proyecto y se abre con `plannotator annotate <archivo>` (por SSH, añade `--tailscale`). Anexa las respuestas literales y aplica solo lo autorizado. SmallDocs está retirado. → `plannotator-vobo.md`

## Herramientas por tema
- Cloudflare: usa el CLI `cf` mediante `cf-arq @perfil`; confirma las escrituras con Rubén. → `cloudflare-cf.md`
- Navegador: Claude in Chrome para sesiones reales, Playwright para flujos aparte y `chrome-devtools` para auditar. Antes de escribir HTML/CSS/JS, consulta `modern-web-guidance`. → `navegador-agentes.md`
- Subagentes: no pases `model` (usa el valor por defecto) salvo que la tarea exija razonamiento difícil; nunca `opus`/`fable` para búsquedas o lecturas.
