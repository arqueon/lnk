## Aviso vigente a todos los agentes — 2026-09-05

Por decisión expresa de Rubén, **arq-unificado en Logseq DB es desde ahora el único grafo operativo de memoria**, para consultas, contexto, journals y nuevas escrituras de todos los agentes. Esto sustituye las instrucciones anteriores que distribuyen información entre arq-graph, arq-academico y arq-personal o los mantienen como destino canónico. Los tres OG quedan conservados como archivo; no añadirles notas ni mantener escrituras paralelas.

- Leer al iniciar la página «Aviso a todos los agentes — Grafo unificado vigente» y «AI Memory Protocol» dentro de arq-unificado.
- En casa, cachyos-ofi y star-lite (cuenta ruben): usar `/home/ruben/.local/bin/logseqdb-cli` con `-g arq-unificado` (`logseq-db-lab-cli` es alias); consultar la ayuda antes de usar opciones. La app se abre con `logseqdb`; grafo en `~/logseq/graphs/arq-unificado`, perfil y credenciales en `~/.config/logseqdb`, API/MCP local en `http://127.0.0.1:12325`. Nunca editar directamente db.sqlite ni escribir Markdown dentro de su carpeta.
- En Sinope: usar el MCP `logseq_db_lab` de Hermes o el MCP privado `http://sinope.tailf70cf8.ts.net:12327/mcp`. Las credenciales viven en la configuración privada del cliente/servicio; nunca copiarlas al grafo ni al chat. Hermes carga el cambio en una sesión nueva; `/reload-mcp` renueva sus herramientas.
- El acceso autorizado comprende el grafo completo, incluido contenido personal, con lectura y escritura. Buscar antes de crear, conservar estructura de bloques y enlazar el contexto con el journal de la fecha correspondiente.
- Si DB/MCP no está disponible, informar el bloqueo y conservar el trabajo pendiente en el proyecto; no usar los OG como destino alternativo ni declarar que algo se registró sin verificarlo.
- Los expedientes de revisión duraderos (`.revision/`) se incorporan al grafo DB mediante CLI/MCP, con etiquetas y enlaces; no se archivan como nuevas páginas Markdown en los grafos OG.

Las referencias operativas a los grafos OG que aparezcan más abajo son históricas y quedan sustituidas por este aviso. No cambia las demás reglas del proyecto.

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
  - *Sesión por SSH* (`SSH_CONNECTION` definido): añadir **siempre** `--tailscale`. Así el servidor queda en 127.0.0.1 y se publica por HTTPS solo en el tailnet. Sin esa opción, Plannotator entra en modo remoto y escucha en `0.0.0.0` sin autenticación. Desde un agente, lanzar con `BROWSER=none setsid nohup … &` para que la sesión sobreviva al reinicio del agente, y vigilar el `--result-file`.
- **Después de recibir la respuesta:** anexar al final del `.md` una sección `## Respuestas (AAAA-MM-DD)` con lo recibido, copiado literalmente, y aplicar solo lo autorizado. Esa sección es la evidencia del VoBo.
- **Si Plannotator no está instalado o falla dos veces:** preguntar con `AskUserQuestion` (o la herramienta equivalente del agente) y registrar la respuesta en el `.md`. No reintentar en bucle.
- **Entregables pulidos para terceros** (informes, slides, PDF o DOCX): usar **Quarto** (`quarto preview` / `quarto render`) y publicar el HTML estático en sinope. No usar enlaces de SmallDocs.
- **Al cerrar una compuerta:** hacer `retain` en Hindsight con la decisión, el motivo y la ruta del `.md`, sin secretos.

No aplica a preguntas breves ni aclaraciones que caben en el chat.

