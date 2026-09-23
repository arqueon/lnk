# Registro pendiente en arq-unificado — menú Google de Niri

Fecha: 2026-09-23

El lanzador de las apps de Google para Niri se trasladó a la configuración común de `lnk` en `.config/niri/scripts/launch-google-apps-menu.sh` y se registró en `.lnk`. Los atajos `Mod+Shift+F2` ya figuran en los perfiles `ofi`, `casa` y `laptop`. Los cambios están publicados en los commits `436b413`, `5a0ba21` y `d2672b0`.

Pendiente: localizar la página de contexto adecuada en `arq-unificado`, registrar este cambio y enlazarla desde el journal del 2026-09-23. No se ha escrito en el grafo: `logseqdb-cli -g arq-unificado` devuelve `Failure(graph lock missing)` aunque la app y el worker figuran activos.
