# Aviso a las sesiones de forja, FD, LIA, FI, PG y preselección · criterios de UX/UI

**Fecha:** 18-nov-2026 · **De:** sesión «Criterios UX/UI no repetitivos» (casa) · **Decidido por Rubén** en tres expedientes de `.revision/` (rutas al final). No interrumpas lo que estés haciendo: aplica esto desde tu próxima pieza de interfaz.

## Para todas

1. **Hay una regla nueva para cualquier interfaz:** `~/.config/lnk/casa.lnk/.agents/rules/criterios-ux-ui.md` (en casa está enlazada como `~/.agents/rules/criterios-ux-ui.md`). Léela completa; es una página. Antes: `cd ~/.config/lnk && git pull --rebase`.
2. **Lo que cambia en la práctica:**
   - Cada proyecto con interfaz lleva una **ficha de UI** en `<proyecto>/diseno/[<identidad>/]`: `patterns.md` (tokens con su porqué, mapa de ejes fijos o abiertos y piezas fijas), `sharp_edges.md`, `validations.md` y `nivel-*.jpg`.
   - Un criterio de ficha o de encargo nombra su **origen en el proyecto** y se comprueba con **sí o no sobre una captura**, midiendo el resultado y no el medio.
   - El piso de accesibilidad se cita desde la regla; no se copia en fichas ni encargos.
   - Dos o tres direcciones solo cuentan como distintas si cambian al menos dos ejes de **estructura**. Tres paletas sobre la misma retícula son una sola.
   - Lo que comparten todas las piezas de una identidad (**piezas fijas**) se fija en la ficha antes de encargar.
   - La ficha manda sobre `tastemaker`: no se usa su tabla de moods ni su movimiento obligatorio.
3. **No hace falta rehacer nada ya entregado.** Aplica a piezas nuevas y a las que se retoquen.

## FD · `cursos-formación-docente-con-ia`

- **Antes de tocar nada, `git pull` en los tres repos:** cursos (`1dd53c2`), `plugin/local_fdudg` (`f43df6d`, 0.25.0) y `theme/theme_spacefd` (`96e4512`, 0.3.2). Hoy cambiaron `tools/produccion/compilar.py`, `tools/produccion/desplegar.sh`, `content/programas/fi.css`, `classes/hook_callbacks.php`, `classes/local/hero.php` y `h5p/fdudg-h5p-full.css`.
- **Pruebas ya tiene** el tema 0.3.2 y el plugin 0.25.0. No despliegues encima un árbol anterior. **La instancia oficial no tiene nada de esto:** va en el siguiente paquete de entrega.
- **`desplegar.sh` usa ahora `tar -h`:** `produccion/<curso>/video` es un enlace simbólico desde el 3-nov y sin seguirlo el importador abortaba con «Archivo ausente o cambiado».
- **FD no cambió:** portada, actividad, Bitácora y un H5P de FD-UCI quedaron idénticos píxel a píxel antes y después. Para un curso de identidad FD, `compilar.py` produce exactamente lo mismo que antes.
- Detalle y evidencia: `.revision/integracion-h5p-pulso-2026-11-18.md` y `diseno/pulso/integracion-2026-11-18/`.

## LIA · FD-LIA (identidad Pulso)

- La ficha de UI de Pulso está en `diseno/pulso/` del repo de cursos. Las maquetas elegidas por Rubén (actividad A, portada A, Bitácora B) están en `diseno/pulso/prueba-2026-11-18/pulido/` y **no están integradas**.
- **Ya integrado en pruebas:** línea del curso en todas las páginas interiores, sangría de 36 px en teléfono y la página del libro interactivo 1.1 con el libro primero y lo explicativo plegado. `compilar.py` reestructura la descripción de todo `H5P.InteractiveBook` en cursos con `"identidad": "pulso"`; FD-LIA-1.1 ya se reimportó.
- El indicador «Capítulo n de 9» lo escribe `local_fdudg/libro`. El caso ramificado y la práctica conservan su descripción arriba.
- La cuenta `qa_fdint_01` quedó en el capítulo 5 del libro 1.1 y su contraseña se restableció; la cuenta `qa_fdlia_02` existe sin matrícula.

## FI · `formacion-integral` (identidad Pulso)

- **Tus cursos de prueba cambiaron de aspecto en pruebas** sin que los tocaras: FI-QA-01, FI-QA-02 y FI-QA-INT tienen identidad `fi`, así que sus páginas interiores muestran ahora la línea del curso en vez de la tarjeta ilustrada y la sangría de teléfono. La portada de cada curso no cambió. Esos tres cursos **no se capturaron antes y después**: revísalos.
- La piel de H5P en Pulso cambió: los controles que la librería pinta con `--color-base` (botón «Leer» del libro, barras, iconos) salen en el acento Pulso y ya no en marino.
- Si compilas con `compilar.py` un curso con `"identidad": "pulso"` que tenga un libro interactivo, su descripción saldrá reestructurada (franja «N capítulos · tiempo», pliegues, «Qué sigue»).
- La ficha de UI de Pulso (`diseno/pulso/` en el repo de cursos de FD) vale también para FI: es la misma identidad.

### FI · novedades del 21-nov-2026 (decisiones de Rubén, `.revision/integracion-ui-pulso-2026-11-21.md` del repo de cursos de FD)

Pruebas tiene ahora `local_fdudg` 0.28.0 y `theme_spacefd` 0.3.4. Rubén decidió que dos piezas valgan para **toda la identidad Pulso**, así que alcanzan a tus cursos:

- **Portada del curso (ya activa en pruebas, sin recompilar).** Todo curso de identidad `fi` con finalización activada muestra a sus estudiantes la portada «Retomo y recorro»: tarjeta «Donde te quedaste», «n de N actividades» y las unidades en columnas. Docentes y modo edición ven la de siempre. No se capturó en ningún curso de FI: revísala en FI-QA-01, FI-QA-02 y FI-QA-INT.
- **Páginas plegadas (al recompilar).** `compilar.py` pliega las páginas de todo curso con `"identidad": "pulso"`: cada `<h2>` sale como parte cerrada; solo abren las que llevan recuadro de Bitácora. Compilé `fi-lia-10h@ocultable` en una copia privada del espejo, sin desplegar: sus diez páginas se pliegan sin error.
- **Riesgo sin verificar:** tus páginas llevan H5P incrustados dentro de partes que nacen cerradas (hasta cuatro por página en `fi-lia-10h`). Un H5P que arranca oculto puede salir con altura equivocada al abrirse. El plugin avisa a H5P con un `resize` al abrir cada parte, pero solo se probó con una página mínima. Compruébalo en tu primera recompilación; `"pagina_plegada": false` en el `curso.json` apaga el plegado en ese curso.
- **Piel de H5P en Pulso (0.3.3 y 0.3.4):** el enunciado de Question Set ya no va pegado al marco; en teléfono «Anterior» queda como flecha para que «Comprobar» y «Terminar» conserven su texto; el contador interno del libro («5 / 10») se oculta; el subtítulo del caso ramificado sale en Literata.
- **Bitácora de Pulso (0.26.0 y 0.28.0):** tablero de estado en vez de la lista con barras, para quien es dueño de la Bitácora.

## PG y preselección

- No se tocó su código ni su sitio. Solo les aplica la regla general: ficha de UI por proyecto cuando haya interfaz que diseñar, y criterios con origen y comprobación sobre captura.

## forja

- La regla afecta a la etapa de producción por prototipo: los encargos de interfaz llevan piso por referencia, ficha y de tres a cinco criterios de pieza. La prueba completa, con sus encargos y dos revisiones ciegas, sirve de ejemplo: `cursos-formación-docente-con-ia/diseno/pulso/prueba-2026-11-18/`.
- La skill `forja` no se modificó.

## Expedientes

- Marco y VoBo: `~/.config/lnk/.revision/marco-criterios-ux-ui-2026-11-17.md`
- Prueba en Pulso: `cursos-formación-docente-con-ia/.revision/resultados-prueba-ui-pulso-2026-11-18.md`
- Integración del libro: `cursos-formación-docente-con-ia/.revision/integracion-h5p-pulso-2026-11-18.md`
- Memoria: Hindsight, bancos `arq-agentes` y `arq-udgplus` (buscar «criterios UX/UI», «Pulso», «piezas fijas»).
