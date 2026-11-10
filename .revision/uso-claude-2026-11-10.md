# Reducir uso de Claude Code según /usage — propuesta de cambios (2026-11-10)

Nada de esto está aplicado todavía. Cada cambio muestra el antes y el después; responde las tarjetas y aplico solo lo que autorices.

## Lo que encontré

| Punto de /usage | Causa real | Dato |
|---|---|---|
| Subagentes `general-purpose` = 20 % | Es un agente **integrado**; no hay archivo de agente ni skill tuya que lo defina. Lo que fija su modelo es `CLAUDE_CODE_SUBAGENT_MODEL=opus` en `~/.claude/settings.json`. | 253 lanzamientos en transcripciones: 109 sin `model` (→ heredan **opus** del ajuste), 81 `sonnet`, 34 `fable`, 29 `opus` explícitos. 207 de ellos desde sesiones abiertas en `~`. |
| `~/AGENTS.md` largo | 19,6 KB y 125 líneas; incluye la plantilla Logseq ya sustituida (líneas 35-55) y manuales completos de cf, Plannotator y navegador. | Es symlink a `~/.config/lnk/casa.lnk/AGENTS.md` (solo casa). |
| MCP `claude-in-chrome` = 17 % | `claudeInChromeDefaultEnabled: true` lo activa en **todas** las sesiones. | 1.043 llamadas, **todas** en sesiones abiertas en `~` (última hoy). Ningún otro proyecto lo ha usado nunca. |

Aviso honesto sobre el punto 3: el 17 % lo gastaron las sesiones de `~`, que sí lo usan. Apagarlo en los otros 54 proyectos solo quita el coste fijo por sesión (instrucciones del servidor + lista de herramientas + sección de sistema), que es pequeño. Si quieres bajar ese 17 % de verdad, la palanca es usar menos capturas de pantalla (`computer`) y más `get_page_text`/`find` en las sesiones de casa.

---

## Cambio 1 — Modelo de los subagentes integrados

**Archivo:** `~/.claude/settings.json`

```diff
   "env": {
-    "CLAUDE_CODE_SUBAGENT_MODEL": "opus"
+    "CLAUDE_CODE_SUBAGENT_MODEL": "sonnet"
   },
```

Afecta a todo subagente lanzado sin `model` explícito (`general-purpose`, `Plan`…). Los que traen modelo propio (Explore = haiku) o que se lanzan con `model` explícito no cambian. No toca el modelo de la sesión principal (`"model": "opus"` sigue igual). Aplica a sesiones nuevas.

:::question
¿Qué modelo por defecto quieres para los subagentes integrados (`CLAUDE_CODE_SUBAGENT_MODEL` en `~/.claude/settings.json`)?

109 de 253 lanzamientos de `general-purpose` usaron este valor. Sonnet sigue siendo capaz para búsqueda e investigación multipaso; haiku es más barato pero flojo en tareas largas.

- [ ] sonnet — cambiar opus→sonnet en settings.json
- [ ] haiku — cambiar opus→haiku en settings.json (máximo ahorro, menos capacidad)
- [ ] Dejar opus — no tocar settings.json

Recommended: sonnet — cambiar opus→sonnet en settings.json
:::

Los otros 63 lanzamientos con `opus`/`fable` explícito los decide el agente principal al llamar. Solo se frenan con una instrucción. Propuesta de línea extra para el nuevo `AGENTS.md` (sección «Herramientas por tema»):

```markdown
- Subagentes: no pases `model` (usa el valor por defecto) salvo que la tarea exija razonamiento difícil; nunca `opus`/`fable` para búsquedas o lecturas.
```

:::question
¿Añado al nuevo `~/AGENTS.md` la línea que pide no lanzar subagentes con `model: opus/fable` salvo tareas difíciles?

- [ ] Añadir la línea — una línea más en AGENTS.md
- [ ] No añadirla — solo cambiar settings.json

Recommended: Añadir la línea — una línea más en AGENTS.md
:::

---

## Cambio 2 — Acortar `~/AGENTS.md` (19,6 KB → 2,4 KB)

Las secciones se **mueven literalmente** (sin reescribir) a `~/.agents/rules/` (directorio existente y vacío); comprobé que todas las líneas de contenido del original quedan en algún archivo. El nuevo `AGENTS.md` conserva lo que casi toda tarea necesita y apunta al detalle.

| Archivo nuevo en `~/.agents/rules/` | Origen (líneas del actual) | Tamaño |
|---|---|---|
| `agent-vault.md` | 2-8 | 1,6 KB |
| `memoria-hindsight.md` | 11-33 (Hindsight + Logseq retirado/Trilium) | 4,0 KB |
| `logseq-historico.md` | 35-55 (plantilla Logseq sustituida, marcada HISTÓRICO) | 1,7 KB |
| `proyectos-y-repos.md` | 56-72 | 2,2 KB |
| `plannotator-vobo.md` | 73-105 | 4,1 KB |
| `cloudflare-cf.md` | 106-118 | 3,7 KB |
| `navegador-agentes.md` | 119-125 | 2,0 KB |

Para que viajen con tus dotfiles: `lnk add --host casa ~/.agents/rules/*.md` (igual que el propio AGENTS.md). Respaldo previo: `casa.lnk/AGENTS.md.bak-uso-2026-11-10`. Los AGENTS.md de abdel, ofi, laptop y star-lite no se tocan.

Mantengo los marcadores `agent-vault-common` alrededor del bloque de credenciales: si el instalador de Agent Vault vuelve a correr, reemplazará ese bloque por la versión larga (solo ese bloque).

**Nuevo `~/AGENTS.md` propuesto (completo):**

```markdown
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
```

:::question
¿Aplico el nuevo `~/AGENTS.md` de casa y muevo las 7 secciones a `~/.agents/rules/` (registradas en lnk con `--host casa`)?

Puedes anotar ajustes al texto propuesto directamente en este documento antes de responder.

- [ ] Aplicar tal cual — respaldo, escribir AGENTS.md, crear 7 archivos, `lnk add --host casa`
- [ ] Aplicar con mis anotaciones — mismo alcance, incorporando lo que marqué
- [ ] No aplicar — dejar AGENTS.md como está

Recommended: Aplicar tal cual — respaldo, escribir AGENTS.md, crear 7 archivos, `lnk add --host casa`
:::

### Algo más que encontré: `~/.claude/CLAUDE.md` duplica casi todo

`~/.claude/CLAUDE.md` (19 KB) repite Agent Vault, Hindsight, Logseq, Plannotator, cf y navegador. En toda sesión abierta en `~` (que es donde ocurre el 80 % de tu uso) Claude Code carga **los dos**: unos 38 KB de instrucciones por sesión, la mitad duplicada. No lo pediste, así que no lo toco sin permiso.

:::question
¿Qué hago con `~/.claude/CLAUDE.md`, que duplica casi todo `~/AGENTS.md` y se carga junto a él en las sesiones de `~`?

- [ ] Reducirlo a un puntero — dejar solo lo exclusivo de Claude Code y remitir a `~/AGENTS.md` y `~/.agents/rules/` (te muestro el texto antes)
- [ ] Dejarlo como está — sin cambios

Recommended: Reducirlo a un puntero — dejar solo lo exclusivo de Claude Code y remitir a `~/AGENTS.md` y `~/.agents/rules/` (te muestro el texto antes)
:::

---

## Cambio 3 — Claude in Chrome solo donde se usa

**Qué proyectos lo necesitan:** solo `~` (`/home/ruben`): 1.043 llamadas, última el 2026-11-10. Ninguno de los otros 54 proyectos registrados en `~/.claude.json` lo ha llamado nunca.

**Opción A (recomendada):** dejar `claudeInChromeDefaultEnabled: true` y añadir `"claude-in-chrome"` a `disabledMcpServers` de cada uno de los 54 proyectos en `~/.claude.json`. Es la misma lista que escribe `/mcp → Disable`, y la puedes revertir por proyecto desde `/mcp`. Respaldo previo: `~/.claude.json.bak-chrome-2026-11-10`. Ejemplo de entrada:

```diff
   "/home/ruben/Nextcloud/Projects/dms/dankmail": {
+    "disabledMcpServers": ["claude-in-chrome"],
     ...
   },
   "/datos/Nextcloud/Projects/zettlr/artículo kenia": {
-    "disabledMcpServers": ["open-design"],
+    "disabledMcpServers": ["open-design", "claude-in-chrome"],
```

Límite: los proyectos **nuevos** seguirán arrancando con Chrome activo hasta que lo apagues en ellos.

**Opción B:** `claudeInChromeDefaultEnabled: false` global. Apagado en todo sitio, incluidos proyectos futuros, pero en `~` tendrías que arrancar con `claude --chrome` (o `/chrome`) cuando lo necesites.

<details><summary>Los 54 proyectos afectados</summary>

/datos/Nextcloud/Projects/credenciales-comunitarias · /datos/Nextcloud/Projects/udgplus/forja · /datos/Nextcloud/Projects/zettlr/Spinoza_mich/video-conatus · /datos/Nextcloud/Projects/zettlr/artículo kenia · ~/.config/DankMaterialShell/plugins/weeklyCalendar · ~/.config/lnk · ~/.config/niri · ~/.config/variety · ~/Documents/Claude · ~/Downloads (y 6 subcarpetas) · ~/Insync/…/Bases reducción de riesgos · ~/Nextcloud/Academia/zettlr/UdeG/IAorientaciones · ~/Nextcloud/Projects/{arq-graph, dms-scrobbler, dms-theme-sync, dms/dankmail, dms/dms-dankcalendar, dms/dms-theme-sync, ia/aprendizaje-ia, ia/humanizar, udgplus/cursos-formación-docente-con-ia, udgplus/microcredenciales, udgplus/pg2026b-redesign (+ 1 worktree), zettlr/UdeG/IAorientaciones} · ~/Projects/{dms-scrobbler, dms-whisper} · /media/insync (y 19 subcarpetas: DATA/…, Insync/Academia/zettlr/…, Insync/UDGPlus/Proyectos/…, arq/BTB/…)

</details>

:::question
¿Cómo apago Claude in Chrome fuera de `~`?

Solo las sesiones abiertas en `/home/ruben` lo han usado (1.043 llamadas); los otros 54 proyectos, nunca.

- [ ] Opción A — añadir `claude-in-chrome` a `disabledMcpServers` en los 54 proyectos de `~/.claude.json`; `~` sigue igual
- [ ] Opción B — `claudeInChromeDefaultEnabled: false` global; en `~` arrancar con `claude --chrome`
- [ ] No tocarlo — dejar Chrome activo en todas partes

Recommended: Opción A — añadir `claude-in-chrome` a `disabledMcpServers` en los 54 proyectos de `~/.claude.json`; `~` sigue igual
:::

---

## Después de aplicar
- Verificar: `jq` sobre settings.json y `~/.claude.json`; `diff` del contenido movido contra el respaldo de AGENTS.md; una sesión de prueba en un proyecto sin Chrome.
- Commit en `~/.config/lnk` (AGENTS.md, rules, este expediente) y `retain` en Hindsight (`arq-agentes`).

## Respuestas (2026-11-10)

```text
5 of 5 questions answered.

### Q1. ¿Qué modelo por defecto quieres para los subagentes integrados (`CLAUDE_CODE_SUBAGENT_MODEL` en `~/.claude/settings.json`)? (line 31)
Answer: sonnet (your recommendation)

### Q2. ¿Añado al nuevo `~/AGENTS.md` la línea que pide no lanzar subagentes con `model: opus/fable` salvo tareas difíciles? (line 49)
Answer: Añadir la línea (your recommendation)

### Q3. ¿Aplico el nuevo `~/AGENTS.md` de casa y muevo las 7 secciones a `~/.agents/rules/` (registradas en lnk con `--host casa`)? (line 107)
Answer: Aplicar tal cual (your recommendation)

### Q4. ¿Qué hago con `~/.claude/CLAUDE.md`, que duplica casi todo `~/AGENTS.md` y se carga junto a él en las sesiones de `~`? (line 123)
Answer: Reducirlo a un puntero (your recommendation)

### Q5. ¿Cómo apago Claude in Chrome fuera de `~`? (line 160)
Answer: Opción A (your recommendation)
```

## Aplicado (2026-11-10)

- Cambio 1: `CLAUDE_CODE_SUBAGENT_MODEL` = `sonnet` (respaldo `~/.claude/settings.json.bak-uso-2026-11-10`). Línea de subagentes añadida a AGENTS.md.
- Cambio 2: `~/AGENTS.md` 19,6 KB → 2,6 KB; 7 archivos en `~/.agents/rules/` registrados con `lnk add --host casa`; comprobado que 0 líneas del original faltan (respaldo `casa.lnk/AGENTS.md.bak-uso-2026-11-10`).
- Cambio 3: `claude-in-chrome` en `disabledMcpServers` de 54 de 55 proyectos; `/home/ruben` intacto (respaldo `~/.claude.json.bak-chrome-2026-11-10`).

---

## Ronda 2 — Texto propuesto para `~/.claude/CLAUDE.md` (19 KB → 0,6 KB)

Comprobación: lo único de CLAUDE.md que no estaba ya en `~/.agents/rules/` es su propia copia de la sección «Memoria duradera → Logseq» (líneas 34-63, sustituida por Hindsight). Se mueve literalmente como apéndice a `~/.agents/rules/logseq-historico.md`.

Punto clave: los proyectos fuera de `~` (`/datos/…`, `/media/insync/…`) **no** cargan `~/AGENTS.md` por sí solos, así que el puntero lo **importa** con `@~/AGENTS.md`. En sesiones de `~` puede cargarse dos veces, pero ahora son 2,6 KB y no 19 KB. Conservo los dos pares de marcadores para que un reinstalador reemplace solo su bloque.

```markdown
<!-- agent-vault-common:start -->
Credenciales: Agent Vault (`av-access --agent claude …`). Detalle: `~/.agents/rules/agent-vault.md`.
<!-- agent-vault-common:end -->

# Instrucciones globales de Rubén para Claude Code

Las reglas comunes a todos los agentes están en `~/AGENTS.md`, que se importa abajo para que también rijan en proyectos fuera de `~` (`/datos/…`, `/media/insync/…`). Su detalle está en `~/.agents/rules/`. Este archivo no las repite.

<!-- revision-local:start v=1 -->
Decisiones y VoBo: Plannotator. Detalle: `~/.agents/rules/plannotator-vobo.md`.
<!-- revision-local:end -->

@~/AGENTS.md
```

Respaldo previo: `~/.claude/CLAUDE.md.bak-uso-2026-11-10`.

:::question
¿Reemplazo `~/.claude/CLAUDE.md` por el puntero de arriba y muevo su sección Logseq (líneas 34-63) como apéndice a `~/.agents/rules/logseq-historico.md`?

- [ ] Aplicar tal cual — respaldo, escribir el puntero de 0,6 KB, añadir apéndice al histórico
- [ ] Aplicar con mis anotaciones — mismo alcance, incorporando lo que marqué
- [ ] No aplicar — dejar CLAUDE.md como está

Recommended: Aplicar tal cual — respaldo, escribir el puntero de 0,6 KB, añadir apéndice al histórico
:::

## Respuestas ronda 2 (2026-11-10)

Plannotator devolvió (literal): «Q6 … Answer: Aplicar tal cual (your recommendation)» y marcó Q3 como «Unanswered». Por la ambigüedad lo confirmé en el chat; respuesta literal de Rubén: «Apply CLAUDE.md pointer».

## Aplicado ronda 2 (2026-11-10)

- `~/.claude/CLAUDE.md` 19 KB → 0,6 KB, puntero que importa `@~/AGENTS.md` (respaldo `~/.claude/CLAUDE.md.bak-uso-2026-11-10`). Su sección Logseq (l. 34-63) pasó como apéndice a `logseq-historico.md`; comprobado que 0 líneas faltan.
- Verificado con `claude -p` en `/datos/Nextcloud/Projects/udgplus/forja`: carga «Reglas para agentes (casa)» y no tiene herramientas `mcp__claude-in-chrome`.
