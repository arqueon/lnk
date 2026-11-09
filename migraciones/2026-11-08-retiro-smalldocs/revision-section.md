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
