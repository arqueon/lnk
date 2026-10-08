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
- Memoria operativa de agentes: Hindsight (ver arriba). SmallDocs duraderos de proyectos → `retain` en Hindsight.

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

## Decisiones, muestras y VoBo → SmallDocs editorial

Toda entrega que requiera **comparar, decidir, revisar una muestra, fijar alcance, solicitar
ajustes o dar VoBo** debe presentarse en SmallDocs, no quedar dispersa únicamente en el chat.
La respuesta conversacional puede resumir el resultado, pero el expediente legible y la
decisión persistida viven en el `.md`.

- Crear el documento dentro del proyecto, normalmente bajo `.sdocs/`, y abrirlo editable en
  segundo plano con `md <archivo.md>`; este atajo ejecuta `sdoc bridge`.
- Si contiene imágenes locales, ejecutar **antes de abrirlo**
  `sdoc-embed-images <archivo.md> --compress`. El helper incrusta WebP de alta nitidez (máximo 1920 px y calidad 88) para preservar el texto y detalles de capturas/gráficos sin bloquear HTTPS. Si se requieren detalles extremadamente finos, puede usarse `--max-dim 2048 --quality 92`.
- Si el documento es masivo o su URL supera aproximadamente 120 KB, generar el enlace corto
  con `sdoc share <archivo.md> --short` y abrir ese enlace en lugar de forzar la URL local.
- Al cerrar, clasificar el SmallDoc: si aporta memoria duradera —decisión confirmada,
  arquitectura, procedimiento, QA o contexto reutilizable— convertirlo en una página real
  bajo `/home/ruben/Nextcloud/Projects/arq-graph/pages/`, con cabecera Logseq y nombre
  enlazable, conservando el front matter/bloques necesarios para SmallDocs. Enlazarlo desde
  la página de contexto y el journal. Muestras efímeras, formularios descartados y entregas
  coyunturales permanecen fuera; no usar un directorio oculto como destino final ni migrar
  todos los SmallDocs indiscriminadamente.
- Si existe una decisión estructurable, incorporar un bloque `form`. **NO usar únicamente `md <archivo.md>` (`sdoc bridge`)**, ya que no mantiene un escuchador activo en el agente y causa que la interfaz se atore en `Sending...` al expirar la sesión. Para solicitar y recibir respuestas, ejecutar **`sdoc feedback <archivo.md>`** en primer plano o mediante una tarea cuyo término/stdout sea observado. Configurar `final: true` en el botón del formulario (o un solo botón final) para que el bridge registre la respuesta y finalice limpiamente con código 0.
- El formulario debe registrar: decisión, alcance, condiciones o ajustes, observaciones
  opcionales y, cuando aplique, autorización de publicación o despliegue.
- Las opciones deben ser concretas y mutuamente distinguibles. La primera puede ser la
  recomendada, pero nunca presentar como tomada una decisión que el usuario no envió.
- Tras el envío, leer `answers`/`submissions`, aplicar solo lo autorizado y conservar esas
  secciones como evidencia de VoBo.
- Para muestras visuales, incluir comparación, criterios y una pregunta de decisión; no
  limitarse a una galería sin contexto.
- Mantener el documento ligero para que el bridge conecte: comprimir imágenes, usar solo las
  necesarias y separar un anexo visual si los data URI vuelven excesivo el Markdown. Confirmar
  que la sesión sigue viva; si no conecta, abrir de inmediato una versión ligera.
- Usar el perfil **Almagre editorial SmallDocs**: papel cálido, texto azul tinta, acento
  almagre, verde olivo, tipografía Lora, tablas editorializadas y contraste AA en claro/oscuro.
  Copiar la plantilla canónica desde la página Logseq
  `[[Protocolo editorial SmallDocs para decisiones y VoBo]]` y ejecutar
  `sdoc color-analysis <archivo.md>` si se usan colores.
- Al cerrar una compuerta, registrar el resultado en la página de contexto de Logseq y en el
  journal del día, enlazando el SmallDoc cuando sea útil y sin copiar secretos.

Esto no aplica a respuestas breves o preguntas simples que no generen artefacto, decisión,
comparación ni autorización.

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
