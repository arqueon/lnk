# AGENTS.md — plantilla canónica (memoria duradera → Logseq)

> Copia o symlinkea este archivo a la raíz de cada proyecto (Antigravity y otros agentes lo leen
> como reglas del workspace), o pega su contenido en Antigravity → Settings → Rules/Memories.

## Memoria duradera → Logseq (fuente de verdad)

La memoria duradera de mis proyectos vive en mi **grafo Logseq** (Markdown, sync Logseq/rsapi),
no en archivos sueltos ni en la memoria nativa del agente. Esa memoria nativa es solo un índice;
si hay conflicto, **gana Logseq**.

- **Grafo:** `/home/ruben/Projects/arq-graph` (en otra máquina: buscar un dir con `pages/`, `journals/`, `logseq/`).
- **Convención de páginas:** cabecera `type:: · area:: · status:: · tags:: · updated::` antes del primer `#`;
  namespaces como carpetas `pages/<Area>/<Tema>.md`; hub por área con queries `{{query (property area [[...]])}}`.
- **Leer al iniciar:** abrir la página-hub del área y sus páginas `type:: [[situación]]`/`[[contexto]]`.
- **Escribir al terminar:** actualizar/crear la página de contexto, enlazar con `[[ ]]`, subir `updated::` (fecha absoluta).
- **Nunca** escribir secretos en el grafo (está en git + sync); referenciar dónde viven y cómo regenerarlos.
- Logseq detecta y actualiza los cambios automáticamente en disco (no es necesario forzar reindexación con `t r`).

Norma completa: página `[[AI Memory Protocol]]` dentro del grafo.
