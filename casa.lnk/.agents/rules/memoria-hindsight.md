# Memoria de agentes: Hindsight; Logseq retirado; Trilium

> Movido literalmente desde ~/AGENTS.md el 2026-11-10.

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
