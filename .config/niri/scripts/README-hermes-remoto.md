# Selector remoto de Hermes

`Mod+Shift+F10` ejecuta `launch-hermes.sh`, muestra un menú y delega en
`hermes-sinope`. El perfil se detecta por host o usuario:

- Rubén: `hermes@sinope`.
- Abdel: `hermes-abdel@sinope` (se muestra como Hermina).

También puede seleccionarse explícitamente desde una terminal:

```bash
hermes-sinope hermes status
hermes-sinope hermes-abdel dashboard
hermes-sinope hermina tui
hermes-sinope hermes tmux-setup
hermes-sinope hermes-abdel tmux-setup
```

La TUI oficial persistente vuelve a aparecer en el selector gráfico después de
que la prueba real del 23 de agosto de 2026 confirmara que responde
correctamente dentro de `tmux`. También se conserva como subcomando para uso
deliberado desde terminal. Los atajos inequívocos son `hermes-tui` para
`hermes@sinope` y `hermina-tui` para `hermes-abdel@sinope`. `hermes tui` no es
equivalente: ejecuta el Hermes local y falla si esa instalación local no tiene
proveedor configurado.

Para el perfil `hermes`, la opción **WebUI comunitaria** abre directamente
`https://hermes.arqueonautis.org/`. Así reutiliza el origen y la sesión del sitio
publicado; abrir el mismo servicio como `http://127.0.0.1:8787/` crea un origen
de navegador distinto y, por tanto, no comparte sus cookies. `hermes-abdel`
continúa usando el túnel privado al puerto `8788`, salvo que se defina
`HERMES_SINOPE_WEBUI_URL` con una URL publicada para ese perfil.

Las interfaces web se publican localmente mediante túneles SSH transitorios de
`systemd --user`. `stop-labs` detiene esos túneles y los cuatro laboratorios,
pero conserva el Gateway y el WebUI principal.

## Requisitos del cliente

- `bash`, OpenSSH, `systemd-run`, `curl`, `jq`, `perl` y las utilidades
  terminfo de ncurses (`infocmp`/`tic`).
- Chrome o `xdg-open` para las interfaces web.
- Uno de `fuzzel`, `rofi`, `zenity` o `kdialog` para el menú.
- Una terminal compatible; `kitty` es la primera opción conocida.
- Acceso SSH autorizado a la cuenta correspondiente en Sinope. Para Abdel, el
  script reconoce `~/.ssh/id_ed25519_hermes_abdel_sinope`.

Desktop y Hermes Gate son opcionales por máquina. El script informa claramente
si faltan. Gate crea o amplía su configuración local al iniciarse, sin guardar
claves ni tokens en `lnk`. Antes de abrir TUI o Gate, el cliente comprueba que
Sinope conozca el tipo de terminal local —por ejemplo, `xterm-kitty`— y copia
solo esa definición pública si hace falta.

La configuración necesaria para que las TUI remotas conserven UTF-8, color y
portapapeles OSC 52 vive en `hermes-remote-tmux.conf`, no en la configuración
personal de Kitty de cada estación. `tmux-setup` valida esa plantilla con la
versión remota de tmux, respalda un `~/.tmux.conf` distinto, instala la copia
canónica en la cuenta seleccionada y recarga los servidores tmux existentes sin
cerrar sus sesiones. También aparece como **Preparar tmux remoto (UTF-8 +
portapapeles)** en el menú. No guarda sesiones, historiales, llaves ni tokens en
`lnk`.

Desktop usa ahora su modo oficial **Connect via SSH** en lugar de inyectar
`HERMES_DESKTOP_REMOTE_URL` y un token. Cada identidad guarda su configuración
en `~/.config/hermes-desktop-sinope/<perfil>/`, separada del Desktop local y con
modo `0600`. El token del túnel permanece efímero cuando la sesión gráfica no
tiene GNOME Keyring/KWallet; el script no activa almacenamiento básico ni
guarda credenciales en texto plano.
