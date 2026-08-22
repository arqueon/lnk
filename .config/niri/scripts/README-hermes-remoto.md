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
```

Las interfaces web se publican localmente mediante túneles SSH transitorios de
`systemd --user`. `stop-labs` detiene esos túneles y los cuatro laboratorios,
pero conserva el Gateway y el WebUI principal.

## Requisitos del cliente

- `bash`, OpenSSH, `systemd-run`, `curl`, `jq` y `perl`.
- Chrome o `xdg-open` para las interfaces web.
- Uno de `fuzzel`, `rofi`, `zenity` o `kdialog` para el menú.
- Una terminal compatible; `kitty` es la primera opción conocida.
- Acceso SSH autorizado a la cuenta correspondiente en Sinope. Para Abdel, el
  script reconoce `~/.ssh/id_ed25519_hermes_abdel_sinope`.

Desktop y Hermes Gate son opcionales por máquina. El script informa claramente
si faltan. Gate crea o amplía su configuración local al iniciarse, sin guardar
claves ni tokens en `lnk`.
