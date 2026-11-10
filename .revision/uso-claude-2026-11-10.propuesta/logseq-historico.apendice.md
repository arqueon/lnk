
---

## Variante que estaba en ~/.claude/CLAUDE.md (líneas 34-63, movida el 2026-11-10)


# Memoria duradera → Logseq (fuente de verdad)

La memoria duradera de mis proyectos vive en mi **grafo Logseq** (Markdown, sync Logseq/rsapi),
no en archivos sueltos. Esta memoria nativa (`~/.claude/`) es solo un índice; si hay conflicto, **gana Logseq**.

- **Grafos (desde 2026-07-13 son TRES, en `~/Projects/` = `~/Nextcloud/Projects/`):**
  - `arq-graph` — el que leo/escribo por defecto: agentes IA, Projects, infraestructura, homelab y docencia UDGPlus.
  - `arq-academico` — lecturas, referencias de internet, highlights, notas intelectuales (destino de Readwise/SendToLogseq).
  - `arq-personal` — casa, salud, familia, trámites. **No leerlo salvo petición explícita de Rubén.**
  - (Las recetas ya no tienen grafo: `arq-recetas` se borró a propósito; la colección curada vive en Mealie, `mealie.arqueonautis.org`; Grocy se retiró el 2026-08-01 y sus datos quedan en sinope `/home/sinope/grocy`.)
  - Al escribir, elegir el grafo por tema; el journal del día se escribe en el grafo donde se trabajó (misma convención en todos).
- **Buscar en el grafo con herramientas nativas (Bash/Grep/Read), no vía MCP**: grep por propiedades (`type::`, `area::`, `status::`) para acotar, leer solo la sección necesaria; barridos amplios → subagente que devuelva síntesis. No leer páginas enteras "para orientarse".
- **Convención de páginas:** cabecera `type:: · area:: · status:: · tags:: · updated::` antes del primer `#`;
  la organización es por `area::`, tags y hubs (las carpetas del sistema de archivos NO forman parte del
  nombre de la página); hub por área con queries `{{query (property area [[...]])}}`.
- **Wikilinks SIEMPRE con el nombre real de la página, sin `/` ni prefijos de área**:
  `[[PG2026B Rediseño]]` ✓ · `[[Proyectos/PG2026B Rediseño]]` ✗ (crea/apunta a otra página y el enlace no conduce).
- **Leer al iniciar:** abrir la página-hub del área y sus páginas `type:: [[situación]]`/`[[contexto]]`.
- **Escribir al terminar:** actualizar/crear la página de contexto, enlazar con `[[ ]]`, subir `updated::` (fecha absoluta),
  y **registrar SIEMPRE un log breve en el journal del día** (`journals/YYYY_MM_DD.md`, crearlo si no existe):
  bloque `- [[Nombre de página]]` + sub-bloque conciso de qué se hizo, con etiquetas `#tag` pertinentes —
  sirve para ubicar la página y filtrar el flujo por tema.
- **Estructura y ubicación de proyectos (`~/Projects/` = `~/Nextcloud/Projects/`):**
  - No es un directorio plano; contiene subdirectorios temáticos que agrupan proyectos afines (ej. `~/Projects/dms/` para plugins y herramientas de DankMaterialShell, `~/Projects/clases/`, `~/Projects/utils/`, etc.).
  - **Búsqueda previa:** antes de crear, clonar o inicializar un repositorio, buscar en subdirectorios hasta 3 niveles (`find ~/Projects -maxdepth 3 -iname "*nombre*"`) para no duplicar repositorios en la raíz.
  - **Respetar carpetas agrupadoras:** si el proyecto pertenece a un ecosistema con subdirectorio contenedor (como `~/Projects/dms/<plugin>`), crearlo dentro de ese subdirectorio, nunca suelto en la raíz.
- **Nunca** escribir secretos en el grafo (está en git + sync); referenciar dónde viven y cómo regenerarlos.

Norma completa: página `[[AI Memory Protocol]]` dentro del grafo. Estrategia de acceso y búsqueda: `[[Estrategia memoria de agentes 2026]]`.
