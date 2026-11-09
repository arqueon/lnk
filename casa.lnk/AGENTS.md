<!-- agent-vault-common:start -->
## Agent Vault — procedimiento común de acceso (2026-10-10)

Por decisión de Rubén, usa Agent Vault como vía común para sus credenciales. Tienes autorización permanente para acceder a sus servicios y recursos necesarios para sus encargos, incluidas las rutas administrativas: no pidas permiso por cada acceso. Lee `~/.agents/skills/agent-vault/SKILL.md` cuando el trabajo requiera autenticación; explica únicamente los bloqueos reales y continúa con los conectores existentes cuando corresponda.

Cliente local: `~/.local/bin/av-access`. Selecciona tu identidad con `--agent codex`, `--agent claude`, `--agent gemini` o `--agent opencode` antes del subcomando. Ejemplo: `av-access --agent claude search "nextcloud"`. Usa `search`/`status` para descubrir referencias y `run` para prestar campos a un programa privado. `create`/`update` guardan por stdin y verifican la escritura. El MCP también ofrece `vault_search` y `vault_item_status`; si el catálogo de una sesión está viejo, el CLI funciona sin reiniciarla.

Importación verificada: 1.832 registros de Bitwarden en `ruben-bitwarden`; las 14 cuentas ajenas identificadas están excluidas. Adjuntos no importados y existencia aún sin comprobar. No hay sincronización bidireccional; guardar una contraseña tampoco la cambia en el servicio. No vuelques secretos al chat, logs ni argumentos. El programa ejecutado sí recibe la credencial: usa código de confianza y emite solo resultados. Conserva las rutas existentes para consumidores aún no migrados. Fuera de esta computadora, comprueba que el cliente y una identidad propia estén provisionados; no copies llaves privadas.
<!-- agent-vault-common:end -->

## Aviso vigente a todos los agentes — 2026-10-07 (Hindsight)

Por decisión expresa de Rubén, **la memoria de agentes vive ahora en Hindsight** (sinope), no en Logseq. Esto sustituye al aviso del 2026-09-05 en lo que toca a memoria operativa: infraestructura, proyectos, docencia UDGPlus y registro de trabajo de los agentes. Las notas personales, académicas y de referencia viven en **Trilium** (Logseq se retiró el 2026-10-08; ver sección más abajo; no escribir en Trilium salvo petición de Rubén).

- **Tres bancos aislados, un MCP por banco** (`hindsight-infra`, `hindsight-udgplus`, `hindsight-agentes`): `arq-infra` (homelab, sinope, NAS, Docker, redes, Cloudflare, Home Assistant, escritorio, respaldos), `arq-udgplus` (docencia UDGPlus/UdeG, Moodle/Open edX, PG2026B, microcredenciales, clases propias), `arq-agentes` (protocolos, convenciones, proyectos en curso, registro de lo hecho). URL `http://100.107.89.3:18888/mcp/<banco>/` (en sinope también `http://127.0.0.1:18888`), cabecera `Authorization: Bearer <clave>`. La clave vive solo en la configuración privada del cliente (y en `~/.config/hindsight/token` en las máquinas de Rubén); nunca en el grafo, el chat ni un repositorio. Si la pregunta cruza ámbitos, consulta los tres.
- **Al iniciar:** `recall` en el banco del área antes de actuar (hay modelos mentales ya redactados: estado de infraestructura, pendientes UDGPlus, flota de agentes…; se leen con `reflect` o desde la interfaz). **Al terminar:** `retain` de decisiones con su motivo, estado actual, trampas y pendientes, con fechas absolutas y contexto; esto sustituye al log en el journal de Logseq.
- **No retener** secretos, tokens ni datos personales sensibles: Memory Defense no está activado, la responsabilidad es de quien escribe.
- **Humanos y terminal:** `hs <infra|udgplus|agentes|todos> "pregunta" [--reflect]`; interfaz `http://100.107.89.3:19999`. Estado y trampas: `~/Projects/utils/hindsight-sinope/RELEVO.md`.
- **Si Hindsight no responde:** informar el bloqueo y dejar el pendiente en el proyecto; no declarar que algo se registró sin verificarlo con un `recall`. Si el MCP de tu sesión no conectó (por ejemplo, se abrió mientras el servidor estaba saturado), reconecta con `/mcp` o reinicia con `claude --continue`, y mientras tanto guarda con `hs retener <banco> "texto"` (usa la API, sin MCP).
- Las instancias de Hermes de Abdel, Gerardo y Ximena **no** se conectan a estos bancos (contienen contexto privado de Rubén y la clave de tenant es única).

### Logseq retirado (2026-10-08) — notas personales, académicas y de referencia → Trilium

Logseq DB (arq-unificado) **se desinstaló** de casa y se dio de baja el sync de sinope (contenedores, túnel, DNS, monitores de Kuma). No escribir ni consultar Logseq; `logseqdb-cli` y el MCP `logseq_db_lab` ya no existen. Las notas personales y académicas viven en **Trilium** (`https://trilium.arqueonautis.org`, clientes nativos por Tailscale); no escribir en Trilium salvo petición de Rubén.

- **Archivo para consulta puntual:** repo restic cifrado en el NAS `/mnt/nas-backups/logseq-retiro` (fuera de Nextcloud; replicado a Google Drive `Backups/sinope/logseq-retiro` por `sinope-offsite.timer`). Clave en sinope `/home/sinope/backups/.logseq-restic-pass` (y en el gestor de Rubén). Contiene Markdown de 9.199 páginas y 1.141 journals, exportación EDN completa, la base SQLite, los assets y el estado del servidor de sync. Se restaura solo lo necesario con `restic restore latest --include <ruta>` en sinope.
- Los tres grafos OG (arq-graph, arq-academico, arq-personal) siguen como archivo de solo lectura.
- La llave de firma del APK de Android del fork está en `~/.local/share/android-signing-logseq-fork` (casa).
- Memoria operativa de agentes: Hindsight (ver arriba). Expedientes de revisión duraderos (`.revision/`) → `retain` en Hindsight.

Las secciones siguientes sobre «Memoria duradera → Logseq» y los logs en el journal quedan sustituidas por este aviso y el de Hindsight. No cambia las demás reglas del proyecto.

---

# AGENTS.md — plantilla canónica (memoria duradera → Logseq)

> Copia o symlinkea este archivo a la raíz de cada proyecto (Antigravity y otros agentes lo leen
> como reglas del workspace), o pega su contenido en Antigravity → Settings → Rules/Memories.

## Memoria duradera → Logseq (fuente de verdad)

La memoria duradera de mis proyectos vive en mi **grafo Logseq** (Markdown, sync Logseq/rsapi),
no en archivos sueltos ni en la memoria nativa del agente. Esa memoria nativa es solo un índice;
si hay conflicto, **gana Logseq**.

- **Grafo:** `/home/ruben/Nextcloud/Projects/arq-graph` (en otra máquina: buscar un dir con `pages/`, `journals/`, `logseq/`).
- **Convención de páginas:** cabecera `type:: · area:: · status:: · tags:: · updated::` antes del primer `#`;
  organizar mediante `area::`, etiquetas y hubs con queries `{{query (property area [[...]])}}`.
- **Enlaces de página:** usar siempre el nombre real, por ejemplo `[[Jellyfin remoto para padres]]`; no incluir `pages/`, rutas de directorio ni el área como prefijo salvo que formen parte real del título.
- **Leer al iniciar:** abrir la página-hub del área y sus páginas `type:: [[situación]]`/`[[contexto]]`.
- **Escribir al terminar:** actualizar/crear la página de contexto, enlazar con `[[ ]]`, subir `updated::` (fecha absoluta); registrar siempre un breve log en el journal del día (`journals/YYYY_MM_DD.md`) apuntando a dicha página (`[[Nombre de página]]`) detallando de forma concisa qué se modificó o creó.
- **Nunca** escribir secretos en el grafo (está en git + sync); referenciar dónde viven y cómo regenerarlos.

Norma completa: página `[[AI Memory Protocol]]` dentro del grafo.

## Estructura y ubicación de proyectos (`~/Projects/`)

`~/Projects` (resuelto canónicamente como `/home/ruben/Nextcloud/Projects/`) no es un directorio plano. Contiene subdirectorios temáticos que agrupan proyectos por ecosistema o dominio (por ejemplo: `~/Projects/dms/` para plugins y herramientas de DankMaterialShell, `~/Projects/clases/`, `~/Projects/utils/`, etc.).

- **Búsqueda previa antes de crear o clonar:** Antes de inicializar un nuevo proyecto, clonar un repositorio o configurar un espacio de trabajo, verificar siempre si ya existe buscando en `~/Projects/` y en sus subdirectorios (hasta 3 niveles de profundidad, p. ej. `find ~/Projects -maxdepth 3 -iname "*nombre*"`).
- **Respetar carpetas contenedoras temáticas:** Si el nuevo proyecto pertenece a un ecosistema que ya dispone de un subdirectorio temático agrupador (como `~/Projects/dms/<plugin>` para extensiones de DMS), debe crearse **dentro de dicho subdirectorio**, nunca suelto en la raíz de `~/Projects/`.
- **Evitar duplicaciones:** No crear clones o workspaces paralelos en la raíz si el proyecto ya pertenece a un subdirectorio temático; usar y mantener la ruta canónica agrupada.

## Repos git en ~/Projects (desde 2026-11-03)

- Cada repo de `~/Projects` viaja **solo por git**: Nextcloud lo excluye (manifiesto `~/Projects/.repos.tsv`, herramienta `repos`, detalle en `~/Projects/utils/repos-sync/RELEVO.md`). Lo que no tenga commit y push **no llega a la otra máquina**.
- **Al terminar una tarea en un repo: commit y push a su rama.** No dejar trabajo solo en local. Si `main` está protegida o el proyecto pide PR, push a una rama propia.
- Repo nuevo: crear su remoto (privado: `sinope@100.107.89.3:git/<nombre>.git`) y darlo de alta con `repos alta <ruta> --maquinas casa,oficina`. Un repo sin alta lo sincroniza Nextcloud como carpeta normal y vuelven los conflictos.
- Lo ignorado por git que deba viajar va en `<repo>.material/` (columna `material` del manifiesto).
- **Nunca crear symlinks dentro de `~/Projects` hacia carpetas reales, ni clonar en `~/Repos`**: Nextcloud no sincroniza symlinks y aplica borrados remotos a través de ellos (incidente del 3-nov-2026).
- Estado: `repos estado` (esta máquina) · `repos flota` (casa, oficina y Hermes).

## Decisiones, muestras y VoBo → Plannotator (desde 2026-11-08; sustituye a SmallDocs)

SmallDocs queda **retirado** como canal de decisiones. Su licencia es Elastic-2.0, que no es libre; el renderizado vive en smalldocs.org y el bridge tiene un tiempo de espera que pierde los envíos. Los `.sdocs/` existentes se conservan como archivo: no se abren nuevos ni se usan `sdoc`, `md` ni `sdoc-embed-images`.

Las entregas que piden **comparar, decidir, revisar una muestra, fijar alcance, solicitar ajustes o dar VoBo** se escriben como Markdown revisable y se abren en **Plannotator** (`plannotator`, licencia MIT/Apache-2.0, local y sin telemetría). No deben quedar dispersas en el chat. La respuesta conversacional resume; el expediente y la decisión viven en el `.md`.

- **Archivo:** va dentro del proyecto, en `.revision/<tema>-AAAA-MM-DD.md`. Se escribe Markdown plano: sin front matter de estilos ni bloques `form`, `chart`, `cells` o `slide`. Las imágenes van con su ruta relativa normal (`![alt](imagenes/x.png)`), sin incrustarlas ni comprimirlas. Los diagramas van en bloques ```mermaid. Límite: 2 MiB por archivo.
- **Preguntas:** se escriben como bloques en el propio documento, y Plannotator los muestra como tarjetas:
  ```markdown
  :::question
  ¿Con qué motor producimos la v5?

  Contexto breve: qué afecta la elección y qué se sabe ya (puede llevar una imagen).

  - [ ] HyperFrames — flujo probado, días de trabajo
  - [ ] Remotion — reconstruir voz y QA, semanas

  Recommended: HyperFrames — flujo probado, días de trabajo
  :::
  ```
  `:::question` admite una sola opción, `:::question-multi` varias y `:::question-text` texto libre. La primera línea es la pregunta, y las opciones se escriben como `- [ ] etiqueta — por qué`. Cada ronda lleva unas 8 preguntas como máximo. Las opciones deben ser concretas, distinguibles entre sí y nombrar la acción y el alcance que autorizan (nunca un «aprobar» a secas). `Recommended:` marca la recomendación, pero nunca se presenta como tomada una decisión que el usuario no envió.
- **Abrir:**
  - *Claude Code* (≥ 2.1.287, con el plugin `plannotator@plannotator`): `plannotator annotate <archivo>` o `/plannotator-annotate <archivo>`. Claude **no espera**: termina el turno y la respuesta llega después como mensaje del plugin. Si se cierra la terminal, se recupera con `claude --continue`.
  - *Codex, Gemini y otros agentes*: correr `plannotator annotate <archivo> --gate --json --result-file .revision/<tema>.respuesta.json` como tarea de fondo observada; el resultado sale por stdout y en el JSON. La otra vía es el Inbox por MCP (`plannotator inbox mcp`) y leer la respuesta con `wait_for_reply`. En Codex, ejecutar con escalación porque abre puerto y navegador.
  - *Solo anotar*, sin compuerta: `plannotator annotate <archivo>`. Las ediciones que Rubén guarde en el navegador se escriben en el archivo.
- **Después de recibir la respuesta:** anexar al final del `.md` una sección `## Respuestas (AAAA-MM-DD)` con lo recibido, copiado literalmente, y aplicar solo lo autorizado. Esa sección es la evidencia del VoBo.
- **Si Plannotator no está instalado o falla dos veces:** preguntar con `AskUserQuestion` (o la herramienta equivalente del agente) y registrar la respuesta en el `.md`. No reintentar en bucle.
- **Entregables pulidos para terceros** (informes, slides, PDF o DOCX): usar **Quarto** (`quarto preview` / `quarto render`) y publicar el HTML estático en sinope. No usar enlaces de SmallDocs.
- **Al cerrar una compuerta:** hacer `retain` en Hindsight con la decisión, el motivo y la ruta del `.md`, sin secretos.

No aplica a preguntas breves ni aclaraciones que caben en el chat.

## Cloudflare → CLI agéntico `cf` (desde 2026-10-02)

Para cualquier operación sobre Cloudflare (DNS, túneles, Access/Zero Trust, caché, Workers, R2, D1, analítica…) usar **`cf`** (`cloudflare/cf`, open beta, instalado con `npm i -g --prefix ~/.local cf`; actualizar igual), no curl a mano. Cuenta única (su ID va dentro de `cf-arq`) con 5 zonas (arqueonautis.org, barbiestesteadoras.org, abdelvidrio.org, goflowproducts.org, analisissustanciaspsicoactivas.org). Página de referencia en arq-unificado: «cf — CLI agéntico de Cloudflare».

- **Descubrir, no adivinar:** `cf cli search "<acción + tipo de recurso>"` → elegir el mejor resultado → `<comando> --help`; detalle de la petición API con `cf schema <comando sin cf>`. No encadenar `--help` anidados. **Consultas de búsqueda anónimas**: sin dominios, IDs, nombres ni correos.
- **Autenticación:** usar el wrapper **`cf-arq [@perfil] <args>`**, que inyecta `CLOUDFLARE_API_TOKEN` desde `~/.config/` sin exponer el secreto: `@dns` (default; Tunnel + Zone.DNS, 5 zonas), `@access` / `@access-arq` (Access: Apps and Policies), `@zone` (Zone Settings, solo BTB). **Desde 2026-10-02 hay además sesión OAuth** (`cf auth login`, 475 scopes, cuenta completa, en `~/.config/cloudflare/config/default.json` con refresh token): `cf` a secas sirve para Workers, Pages, AI Gateway, caché, etc. Preferir `cf-arq` cuando el alcance acotado basta (menor riesgo); usar `cf` a secas para lo demás. Si `cf auth whoami` da `authenticated: false`, pedir a Rubén `! cf auth login`. R2 no está activado en la cuenta (403 hasta activarlo en el panel). Nunca imprimir, copiar al chat ni al grafo un token.
- **Ejemplos verificados:** `cf-arq zones list` · `cf-arq dns records list --zone arqueonautis.org` · `cf-arq tunnels list` · `cf-arq @access zero-trust access applications list`.
- La salida es JSON (compacta automáticamente si detecta agente: `CLAUDECODE`, `CODEX_THREAD_ID`, `GEMINI_CLI`, `CURSOR_AGENT`; otros agentes exportan `AI_AGENT=1`). Filtrar con `jq`/python en vez de volcarla entera.
- **Escrituras** (crear/borrar DNS, ingress de túnel, políticas Access, purgas): mostrar antes el comando y el objeto afectado y confirmar con Rubén salvo autorización expresa; leer el estado actual primero. `cf-btb list|add <sub|fqdn> <puerto>|del <sub|fqdn> [--dry-run]` (reescrito sobre `cf` el 2026-10-02: conserva `warp-routing`, admite cualquier zona, respalda en `~/.local/state/cf-btb/`) es la vía para publicar hostnames en el túnel remoto nas-btb; el ingress de sinope es local (`/etc/cloudflared/config.yml`: respaldar, `cloudflared tunnel --config <candidato> ingress validate`, reiniciar). `cf-btb-access-fix` sigue para su caso.
- Telemetría desactivada (`cf cli telemetry disable`; el wrapper fuerza `CF_SEND_TELEMETRY=false`). En Codex, `cf` necesita red y lectura de `~/.config/cf-*-token`: ejecutar con escalación autorizada.
- **Otras máquinas:** sinope tiene `cf` global (`npm i -g cf`, telemetría apagada para root/sinope/hermes) pero **sin sesión ni tokens**: para operar desde allí, Rubén hace `cf auth login` con el usuario que corresponda. Trampa: `cf` lee un `.env` del directorio actual y falla con EACCES si no puede (p. ej. `sudo -u X` desde /root): hacer `cd ~` antes. En cachyos-ofi, star-lite y ruben-laptop aún no está: `npm i -g --prefix ~/.local cf && cf cli telemetry disable`.
- **Vigía de túneles:** `cf-tuneles-vigia.timer` en sinope (cada 5 min) avisa por ntfy (tema `sistema`) si un túnel pasa a degraded/down y cuando se recupera; token de solo lectura en `/etc/cloudflare/cf-tunnel-read-token` (permiso «Argo Tunnel (Legacy) · Read»; instalado 2026-10-02). Auditoría DNS↔túneles: `~/Projects/utils/cloudflare-cf/auditar-dns-tuneles.sh`.

## Navegador para agentes: qué herramienta usar (desde 2026-10-26)

- **Claude in Chrome** → acciones en el Chrome real de Rubén con sus sesiones (Classroom, Gmail web, paneles con login). **Playwright MCP** → automatizar flujos y formularios en un navegador aparte.
- **`chrome-devtools` (CLI de Chrome DevTools MCP 1.12, en `~/.local/bin`)** → **auditar y diagnosticar**: `lighthouse_audit <pageId> --device mobile` (accesibilidad, buenas prácticas, SEO, «agentic browsing»), trazas de rendimiento/LCP, `get_css_styles` (cascada, heredados, `@keyframes`, at-rules), red y heap snapshots (closures retenidas). Es un daemon: `new_page <url>` → `list_pages` → herramienta con `<pageId>` → `stop` al terminar. Config global en `~/.config/cd4a/config.json`: Chromium del sistema, headless, perfil aislado sin cookies, **sin telemetría ni envío de URLs a CrUX** (importa para Moodle/sinope internos), cabeceras redactadas, capturas WebP ≤1400 px. Skills: `chrome-devtools-cli`, `a11y-debugging`, `debug-optimize-lcp`, `memory-leak-debugging`, `cookie-debugging` (escritas para MCP: cada herramienta es `chrome-devtools <herramienta>`). No está registrado como servidor MCP a propósito, para no cargar ~40 esquemas en cada sesión; si hace falta: `claude mcp add chrome-devtools -- chrome-devtools-mcp`.
- **`modern-web-guidance`** (skill + CLI local, sin red) → antes de escribir HTML/CSS/JS de cliente (Hugo, temas Moodle, SmallDocs, artifacts, H5P): `modern-web-guidance search "<2-5 palabras>"` → `retrieve <id>`. Prioriza lo nativo (dialog/popover, anchor positioning, `:user-valid`, View Transitions) sobre dependencias.
- Telemetría desactivada en `~/.config/environment.d/20-web-telemetria.conf` (`CHROME_DEVTOOLS_MCP_NO_USAGE_STATISTICS=1`, `DISABLE_TELEMETRY=1`; se aplica al iniciar sesión). Actualizar: `npm i -g --prefix ~/.local chrome-devtools-mcp@latest modern-web-guidance@latest`; las skills son symlinks al paquete y se actualizan solas.
