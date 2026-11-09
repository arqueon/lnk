## Decisiones, muestras y VoBo → Plannotator (desde 2026-11-08; sustituye a SmallDocs)

SmallDocs está **retirado** y desinstalado: no uses `sdoc`, `md` ni `sdoc-embed-images`. Los `.sdocs/` existentes se conservan como archivo.

Cuando Rubén deba **comparar, decidir, revisar una muestra, fijar alcance o dar VoBo**, el expediente vive en un Markdown, no solo en Discord:

- **Archivo:** dentro del proyecto, en `.revision/<tema>-AAAA-MM-DD.md`. Markdown plano: imágenes con su ruta relativa normal y diagramas en ```mermaid.
- **Preguntas:** van como bloques en el documento. `:::question` admite una opción, `:::question-multi` varias y `:::question-text` texto libre. Cada bloque se cierra con `:::`. Las opciones se escriben como `- [ ] etiqueta — por qué` y la recomendada se marca con `Recommended: <etiqueta>`. Las opciones deben ser concretas y nombrar la acción y el alcance que autorizan. Nunca presentes como tomada una decisión que Rubén no envió.
- **Abrir (sinope no tiene escritorio):** `BROWSER=none setsid nohup plannotator annotate <archivo> --tailscale --gate --json --result-file .revision/<tema>.respuesta.json > /tmp/plannotator-<tema>.log 2>&1 &`. Toma del log la URL `https://sinope.tailf70cf8.ts.net:<puerto>` (solo es accesible en el tailnet), mándala a Rubén por Discord y vigila el `--result-file`. **Nunca** lo lances sin `--tailscale`: en modo remoto escucha en `0.0.0.0` sin autenticación.
- **Si `plannotator` no está instalado o `--tailscale` falla:** haz las mismas preguntas en Discord, con opciones numeradas, y registra la respuesta en el `.md`. No reintentes en bucle.
- **Después de recibir la respuesta:** anexa al final del `.md` una sección `## Respuestas (AAAA-MM-DD)` con lo recibido, copiado literalmente, y aplica solo lo autorizado. Al cerrar, haz `retain` en Hindsight con la decisión, el motivo y la ruta.
- **Entregables pulidos** (informes, slides, PDF): usa Quarto si está disponible; si no, entrega el Markdown.
