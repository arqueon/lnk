# Criterios de UX/UI

> Desde 2026-11-17. VoBo y razones: `~/.config/lnk/.revision/marco-criterios-ux-ui-2026-11-17.md`. En prueba con los cursos de identidad Pulso (FD-LIA y FI). Prioridad de la prueba: que lo producido no se parezca de un proyecto a otro.

Un criterio se repite cuando puede copiarse a otro proyecto sin cambiarle una palabra. Aplica a toda interfaz que no sea una herramienta interna desechable.

## Tres niveles

- **Piso** (idéntico en todo proyecto; se cita, no se copia en fichas ni encargos): contraste AA (4.5:1 en texto, 3:1 en componentes), todo operable con teclado y foco visible, 390 px sin desplazamiento horizontal, zoom 200 %, modo oscuro, `prefers-reduced-motion` respetado. Se mide con herramienta: `chrome-devtools lighthouse_audit <pageId> --device mobile` y un comprobador de contraste. Lo técnico de HTML/CSS/JS sigue en `navegador-agentes.md`.
- **Identidad** (propia del proyecto): vive en la ficha de UI.
- **Pieza** (propia de cada pantalla): vive en el encargo. Parte de lo que la persona viene a hacer en esa pantalla.

## Forma de un criterio de identidad o de pieza

1. **Eje:** uno solo (ver la lista).
2. **Origen:** de qué sale en este proyecto (contenido, audiencia, referencia, restricción). Sin origen propio es piso o es relleno.
3. **Regla y lo que desplaza:** qué se hace y qué default deja fuera.
4. **Comprobación:** pregunta de sí o no que se contesta mirando una captura. Mide el resultado, no el medio: «¿la página cabe en tres pantallas?» y no «¿hay un índice?». En la prueba de Pulso (18-nov-2026) una maqueta pasó «hay una lista de las partes» y la página siguió midiendo 16 800 px.

## Filtros (el criterio entra solo si pasa los cuatro)

- **Trasplante:** ¿se podría copiar tal cual a otro proyecto? Entonces baja a piso o se elimina.
- **Negación:** ¿alguien razonable habría hecho lo contrario? Si no, no decide nada.
- **Captura:** ¿se contesta sí o no mirando un render, sin leer el código? Si no, se reescribe.
- **Duplicado:** ¿ya lo cubre el piso, una skill o la ficha? Se cita, no se repite.

## Ejes

- **Estructura:** composición y retícula · densidad · orden de entrada · navegación.
- **Superficie:** tipografía · color · forma (radios, bordes, sombras) · material o textura · tipo de imagen · movimiento.
- **Conducta:** estados (vacío, error, carga) · retroalimentación · voz del texto de interfaz.

La ficha declara cada eje como **fijo** (identidad) o **abierto** (lo decide la pieza). Al menos dos ejes de estructura quedan abiertos. Una dirección alternativa cuenta como distinta solo si cambia al menos dos ejes de estructura: tres paletas sobre la misma retícula son una sola dirección. Dos proyectos que solo difieren en ejes de superficie son el mismo diseño con otra piel: antes de cerrar una ficha, compara sus capturas con las de otro proyecto de Rubén.

## Piezas fijas

Abrir ejes por pieza rompe lo que las piezas comparten. Antes de encargar, la ficha declara las **piezas fijas**: los componentes que son iguales en todas las piezas de la identidad (encabezado o línea del proyecto, navegación propia, pie) con su medida, y ningún encargo los rediseña. En la prueba de Pulso (18-nov-2026) cuatro encargos resolvieron la línea del curso de cuatro maneras.

## Encargo y verificación

- **Encargo:** piso por referencia a este archivo, la ficha del proyecto y de tres a cinco criterios de pieza. Nada más.
- **Direcciones:** dos o tres antes de pulir; se eligen con capturas.
- **Verificación:** capturas a 390 px y escritorio, en claro y oscuro. El piso lo mide la herramienta. La ficha y la pieza las contesta un revisor que no vio el código.
- **Serie:** las capturas de las piezas hermanas se ponen juntas. ¿Dos piezas con contenido distinto comparten la misma composición?
- **Memoria:** cada defecto añade una línea a `sharp_edges.md`. Para añadir un criterio a la ficha se funde o se retira otro.

## Ficha de UI (plantilla)

El molde de `laboratorio-video/estilos/`. Si el repo tiene varias identidades, una carpeta por identidad.

```
<proyecto>/diseno/[<identidad>/]
  patterns.md           una página: tokens con su justificación y mapa de ejes
  sharp_edges.md        lo que ya falló, con la pieza y la captura; no se borra, se marca «resuelto en …»
  validations.md        preguntas de sí o no sobre capturas; ninguna de gusto
  nivel-390.jpg         el listón en teléfono
  nivel-escritorio.jpg  el listón en escritorio
```

Esqueleto de `patterns.md`:

```markdown
# <Identidad> · patterns

## Rasgo propio
Una frase: qué hace reconocible esta interfaz sin ver el logotipo.

## Tokens y su porqué
| Token | Valor | Por qué en este proyecto |

## Mapa de ejes
| Eje | Fijo o abierto | Regla o margen | Default que desplaza |

## Piezas fijas
Lo que comparten todas las piezas, con su medida. Ningún encargo lo rediseña.

## Prohibiciones propias
Solo las que no valdrían en otro proyecto.
```

## `tastemaker` y `frontend-design`

La ficha es la fuente de la identidad. Con ficha, `tastemaker` queda subordinado y no se edita:

- `.tastemaker/style-lock.md` se deriva de la ficha; si se contradicen, manda la ficha.
- No se usa la tabla de *moods* de `references/style-tokens.md` para elegir paleta o fuente.
- El movimiento no es obligatorio: lo decide el eje «movimiento» de la ficha.
