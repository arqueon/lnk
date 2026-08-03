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

## Producción y revisión de contenidos educativos → diseño instruccional agéntico

Para crear, revisar o adaptar cursos, módulos, unidades, secuencias didácticas,
microcredenciales, guías para estudiantes o docentes, documentos de orientación educativa,
guiones, rúbricas, evaluaciones, sitios formativos, recursos visuales o materiales que verá una
audiencia real, usar siempre la skill:
`/home/ruben/Projects/ia/diseno-instruccional-agentico/SKILL.md`.

- Material para audiencias reales se trabaja por defecto en modo **copiloto**. El modo
  autónomo solo produce prototipos no desplegables.
- El estado vive en un **Pasaporte del curso** dentro del proyecto, basado en
  `assets/pasaporte-curso.yaml`; no se reconstruye desde la conversación.
- Orden obligatorio: población y contexto → resultados → evidencias y evaluación → compuerta
  de alineación → columna de tareas → narrativa → materiales.
- No producir ni reescribir materiales antes de cerrar A1–A5 de la compuerta de alineación.
  Las verificaciones A6–A8 pueden quedar abiertas únicamente con justificación registrada.
- Diseñar tareas completas con complejidad creciente y andamiaje decreciente. Para públicos
  heterogéneos, separar núcleo, puente y profundización con la misma evidencia.
- Separar siempre la **arquitectura interna** del **artefacto público**. Códigos de resultados,
  tareas, módulos, fases y compuertas permanecen en el pasaporte o el expediente; no se copian
  a guías, cursos, orientaciones, sitios o SVG.
- El artefacto público debe ser didáctico, divulgativo, ilustrativo, accesible y reiterativo.
  Desarrollar cada idea en prosa mediante una situación reconocible, explicación, relaciones,
  ejemplo, contraste, uso y recapitulación antes de resumirla en tablas, listas o figuras.
- Cerrar la compuerta de comprensibilidad con un lector en frío que reciba solo el artefacto y
  pueda explicar de qué trata, por qué importa, qué ejemplo muestra la idea y cómo continuar.
  Una puntuación automática de claridad no basta.
- Medir carga real y dificultad del texto; si el nivel no se midió, declararlo como
  **no verificado**.
- Separar generación y evaluación. El evaluador cita evidencia y no reescribe; el optimizador
  atiende solo los hallazgos y no se autoaprueba. Ejecutar dos rondas antes de cualquier
  despliegue.
- Pilotar con perfiles simulados para detectar términos no definidos, relaciones no explicadas,
  referentes ambiguos, instrucciones sin criterio, tablas o visuales sin mediación, saltos de
  ritmo y prerrequisitos silenciosos. Esto no sustituye la validación humana final.
- Registrar compuertas, patrones de error, decisiones y validación humana en el pasaporte y en
  la página Logseq `[[Protocolo de diseño instruccional agéntico para UDGPlus]]`.
