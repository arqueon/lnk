# Selector remoto de Hermes

`Mod+Shift+F10` ejecuta `launch-hermes.sh`, muestra las tres entradas diarias
(**Webapp oficial**, **Desktop oficial** si está instalado y **TUI oficial
persistente (tmux)**) y delega en `hermes-sinope`. El perfil se detecta por
host o usuario:

- Rubén: `hermes@sinope`.
- Abdel: `hermes-abdel@sinope` (se muestra como Hermina).

También puede seleccionarse explícitamente desde una terminal:

```bash
hermes-sinope hermes status
hermes-sinope hermes-abdel dashboard
hermes-sinope hermina tui
hermes-sinope hermes tmux-setup
hermes-sinope hermes-abdel tmux-setup
hermes-sinope stop-tunnels
```

La TUI oficial persistente cuenta con atajos inequívocos (`hermes-tui` para
`hermes@sinope` y `hermina-tui` para `hermes-abdel@sinope`). `hermes tui` no es
equivalente: ejecuta el Hermes local y falla si esa instalación local no tiene
proveedor configurado.

Para el perfil `hermes`, la opción **Webapp oficial** abre directamente
`https://hermes.arqueonautis.org/` (apuntado al Webapp del gateway en `:9120`).
Para `hermes-abdel`, abre un túnel SSH privado al Webapp oficial en `:9121`,
salvo que se defina `HERMES_SINOPE_WEBUI_URL` con una URL publicada para ese
perfil.

Las interfaces web locales (`webui` en Abdel y `dashboard` en `:9119`) usan
túneles SSH transitorios de `systemd --user`. `stop-tunnels` detiene esos
túneles locales sin tocar los servicios remotos en Sinope (como
`hermes-dashboard-lab.service`, del que depende la app móvil Android).

## Requisitos del cliente

- `bash`, OpenSSH, `systemd-run`, `curl`, `jq` y las utilidades terminfo de
  ncurses (`infocmp`/`tic`).
- Chrome o `xdg-open` para las interfaces web.
- Uno de `fuzzel`, `rofi`, `zenity` o `kdialog` para el menú.
- Una terminal compatible; `kitty` es la primera opción conocida.
- Acceso SSH autorizado a la cuenta correspondiente en Sinope. Para Abdel, el
  script reconoce `~/.ssh/id_ed25519_hermes_abdel_sinope`.

Desktop y Hermes Gate son opcionales por máquina. Gate y `tmux-setup` siguen
disponibles desde `hermes-sinope` en terminal. Antes de abrir TUI o Gate, el
cliente comprueba que Sinope conozca el tipo de terminal local —por ejemplo,
`xterm-kitty`— y copia solo esa definición pública si hace falta.

La configuración necesaria para que las TUI remotas conserven UTF-8, color y
portapapeles OSC 52 vive en `hermes-remote-tmux.conf`. `tmux-setup` valida esa
plantilla con la versión remota de tmux, respalda un `~/.tmux.conf` distinto,
instala la copia canónica en la cuenta seleccionada y recarga los servidores tmux
existentes sin cerrar sus sesiones.

Desktop usa su modo oficial **Connect via SSH** y guarda su configuración en
`~/.config/hermes-desktop-sinope/<perfil>/`, separada del Desktop local y con
modo `0600`.
