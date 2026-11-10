# Proyectos y repos git en ~/Projects

> Movido literalmente desde ~/AGENTS.md el 2026-11-10.

## Estructura y ubicación de proyectos (`~/Projects/`)

`~/Projects` (resuelto canónicamente como `/home/ruben/Nextcloud/Projects/`) no es un directorio plano. Contiene subdirectorios temáticos que agrupan proyectos por ecosistema o dominio (por ejemplo: `~/Projects/dms/` para plugins y herramientas de DankMaterialShell, `~/Projects/clases/`, `~/Projects/utils/`, etc.).

- **Búsqueda previa antes de crear o clonar:** Antes de inicializar un nuevo proyecto, clonar un repositorio o configurar un espacio de trabajo, verificar siempre si ya existe buscando en `~/Projects/` y en sus subdirectorios (hasta 3 niveles de profundidad, p. ej. `find ~/Projects -maxdepth 3 -iname "*nombre*"`).
- **Respetar carpetas contenedoras temáticas:** Si el nuevo proyecto pertenece a un ecosistema que ya dispone de un subdirectorio temático agrupador (como `~/Projects/dms/<plugin>` para extensiones de DMS), debe crearse **dentro de dicho subdirectorio**, nunca suelto en la raíz de `~/Projects/`.
- **Evitar duplicaciones:** No crear clones o workspaces paralelos en la raíz si el proyecto ya pertenece a un subdirectorio temático; usar y mantener la ruta canónica agrupada.

## Repos git en ~/Projects (desde 2026-11-03)

- Cada repo de `~/Projects` viaja **solo por git**: Nextcloud lo excluye (manifiesto `~/Projects/.repos.tsv`, herramienta `repos`, detalle en `~/Projects/utils/repos-sync/RELEVO.md`). Lo que no tenga commit y push **no llega a la otra máquina**.
- **Al terminar una tarea en un repo: commit y push a su rama.** No dejar trabajo solo en local. Si `main` está protegida o el proyecto pide PR, push a una rama propia.
- Repo nuevo: crear su remoto (privado: `sinope@100.107.89.3:git/<nombre>.git`) y darlo de alta con `repos alta <ruta> --maquinas casa,oficina`. Un repo sin alta lo sincroniza Nextcloud como carpeta normal y vuelven los conflictos.
- Lo ignorado por git que deba viajar va en `<repo>.material/` (columna `material` del manifiesto).
- **Nunca crear symlinks dentro de `~/Projects` hacia carpetas reales, ni clonar en `~/Repos`**: Nextcloud no sincroniza symlinks y aplica borrados remotos a través de ellos (incidente del 3-nov-2026).
- Estado: `repos estado` (esta máquina) · `repos flota` (casa, oficina y Hermes).
