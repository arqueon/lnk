## Aviso vigente a todos los agentes — 2026-09-05

Por decisión expresa de Rubén, **arq-unificado en Logseq DB es desde ahora el único grafo operativo de memoria**, para consultas, contexto, journals y nuevas escrituras de todos los agentes. Esto sustituye las instrucciones anteriores que distribuyen información entre arq-graph, arq-academico y arq-personal o los mantienen como destino canónico. Los tres OG quedan conservados como archivo; no añadirles notas ni mantener escrituras paralelas.

- Leer al iniciar la página «Aviso a todos los agentes — Grafo unificado vigente» y «AI Memory Protocol» dentro de arq-unificado.
- En casa: usar `/home/ruben/.local/bin/logseq-db-lab-cli` con `-g arq-unificado`; consultar la ayuda antes de usar opciones. Nunca editar directamente db.sqlite ni escribir Markdown dentro de su carpeta.
- En Sinope: usar el MCP `logseq_db_lab` de Hermes o el MCP privado `http://sinope.tailf70cf8.ts.net:12327/mcp`. Las credenciales viven en la configuración privada del cliente/servicio; nunca copiarlas al grafo ni al chat. Hermes carga el cambio en una sesión nueva; `/reload-mcp` renueva sus herramientas.
- El acceso autorizado comprende el grafo completo, incluido contenido personal, con lectura y escritura. Buscar antes de crear, conservar estructura de bloques y enlazar el contexto con el journal de la fecha correspondiente.
- Si DB/MCP no está disponible, informar el bloqueo y conservar el trabajo pendiente en el proyecto; no usar los OG como destino alternativo ni declarar que algo se registró sin verificarlo.
- Los SmallDocs duraderos se incorporan al grafo DB mediante CLI/MCP, con etiquetas y enlaces; no se archivan como nuevas páginas Markdown en los grafos OG.

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
