# AGENTS.md — plantilla canónica (memoria duradera → Logseq)

> Copia o symlinkea este archivo a la raíz de cada proyecto (Antigravity y otros agentes lo leen
> como reglas del workspace), o pega su contenido en Antigravity → Settings → Rules/Memories.

## Memoria duradera → Logseq (fuente de verdad)

La memoria duradera de mis proyectos vive en mi **grafo Logseq** (Markdown, sync Logseq/rsapi),
no en archivos sueltos ni en la memoria nativa del agente. Esa memoria nativa es solo un índice;
si hay conflicto, **gana Logseq**.

- **Grafo:** `/home/ruben/Nextcloud/Projects/arq-graph` (en otra máquina: buscar un dir con `pages/`, `journals/`, `logseq/`).
- **Convención de páginas:** cabecera `type:: · area:: · status:: · tags:: · updated::` antes del primer `#`;
  namespaces como carpetas `pages/<Area>/<Tema>.md`; hub por área con queries `{{query (property area [[...]])}}`.
  * **Evitar anidación profunda de namespaces**: Para propuestas, RFCs o notas de proyectos, no crear namespaces anidados profundamente (ej. evitar `pages/Projects/dankcalendar/propuesta.md` -> `[[Projects/dankcalendar/propuesta]]`). En su lugar, preferir páginas planas directly en `pages/` (ej. `pages/propuesta.md` -> `[[propuesta]]`) o con un único nivel de namespace (`[[Projects/propuesta]]`), y conectarlas usando las propiedades de la página (`project:: [[Projects/dankcalendar]]`).
- **Leer al iniciar:** abrir la página-hub del área y sus páginas `type:: [[situación]]`/`[[contexto]]`.
- **Escribir al terminar:** actualizar/crear la página de contexto, enlazar con `[[ ]]`, subir `updated::` (fecha absoluta); registrar siempre un breve log en el journal del día (`journals/YYYY_MM_DD.md`) apuntando a dicha página (`[[Nombre de página]]`) detallando de forma concisa qué se modificó o creó.
- **Nunca** escribir secretos en el grafo (está en git + sync); referenciar dónde viven y cómo regenerarlos.

Norma completa: página `[[AI Memory Protocol]]` dentro del grafo.
