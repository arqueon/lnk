# Herdr y memoria en `cachyos-ofi`: auditoría completa contra OOM y arreglo de raíz (2026-11-10)

Las **6 sesiones de `oficina` ya están reanudadas** y visibles en tu Herdr de casa, y el traslado de `/tmp/fi-cadena` a `/var/tmp/fi-cadena` ya liberó **+10 GiB de RAM** en `cachyos-ofi` (`17 GiB` disponibles ahora).

Abajo está la radiografía completa de qué se come los **32 GiB de RAM** de `cachyos-ofi` (la mitad de los 64 GiB de casa) y las tarjetas para quitar lo superfluo y blindar Herdr. Responde las tarjetas (un total de 7) y aplico únicamente lo que marques.

---

## Radiografía real de memoria en `cachyos-ofi` (32 GiB RAM + 31 GiB zram)

Además de los **12.8 GiB en `/tmp` (`tmpfs` = RAM)** que dispararon el corte de hoy (`9.9 GiB` de `fi-cadena` ya movidos + `2.9 GiB` de `claude-1000`), esto es lo que está corriendo **ahora mismo** en `cachyos-ofi` sumando RSS + Swap:

| Grupo en `cachyos-ofi` | Total (RSS + Swap) | Procesos | Observación |
|---|---:|---:|---|
| `Firefox` | **6,133 MB** (2,257 + 3,876) | 25 | Navegador 1 de 3 abiertos a la vez |
| `Ferdium` (Electron) | **6,044 MB** (3,832 + 2,213) | 31 | En `~/.config/autostart/ferdium.desktop` |
| `Chrome Beta` (sesión principal) | **4,409 MB** (2,801 + 1,608) | 34 | Navegador 2 de 3 abiertos a la vez |
| **MCPs stdio multiplicados por sesión** | **~3,720 MB** | 38+ | **Corren dentro de `hc-hold`** (se multiplican ×6–7 sesiones Claude; detalle abajo) |
| `Herdr App + herdr-core + 6 agentes` | **3,068 MB** (2,926 + 143) | 72 | Tu trabajo real en `hc` |
| `Zotero` | **1,667 MB** (503 + 1,164) | 12 | App de escritorio abierta |
| `Claude Desktop` (GUI Electron + Cowork) | **1,413 MB** (912 + 501) | 20 | Tiene una sesión Cowork colgada desde ayer esperando un `.respuesta.json` |
| `DankMaterialShell` (`qs`) | **1,375 MB** (750 + 625) | 3 | Shell del escritorio |
| `hermes-chrome.service` + túnel CDP | **1,133 MB** (687 + 446) | 15 | Navegador 3 de 3 (`chrome-hermes` en puerto 9222 para Hermes) |
| `Anytype` (GUI Electron) | **706 MB** (377 + 329) | 11 | App Electron abierta (notas migradas a Trilium/Hindsight) |
| `Codex app-server --remote-control` | **547 MB** (50 + 497) | 2 | Demonio en segundo plano de Codex |
| `Strata` | **472 MB** (81 + 391) | 2 | Corriendo en segundo plano |
| `zsh` huérfanos (PPID `systemd --user`) | **382 MB** (171 + 211) | 75 | Huérfanos desde ayer |
| `TriliumNext` + `Bitwarden` (Electron) | **~700 MB** (~350 c/u) | 14 | Bitwarden está en `autostart` (además de Agent Vault) |
| `Nextcloud` (166M) + `Insync` (162M) | **328 MB** | 2 | Ambos en `autostart` (+ `rclone-gdrive.service` y `expandrive` en `autostart`) |
| `Herdr TUI 0.9.5` viejo + plugins Bun | **115 MB** | 17 | Servidor viejo sin agentes (`herdr-server.service`) |
| `Mission Control` + `Collie` (zombis) | Fallando c/15 s | 4 | **Ya retirados en casa/sinope**, quedaron encendidos en oficina porque estaba offline |

*(No toco los 10 servicios `b3d-vigia-*.service`, `b3d-entrega-universal.service` ni `fi-cola-voz-listos.service` porque son vigías activos de la producción de cursos FI).*

---

## 1. MCPs stdio globales: el multiplicador oculto dentro de `hc-hold` (~3.7 GiB)

Como todos los agentes de Herdr viven dentro de un solo cgroup (`hc-hold-*.service`), **cada MCP stdio global de `~/.claude.json` levanta un proceso `npm exec` + `node`/`python` por cada sesión abierta de Claude Code** (y además en Claude Desktop), inflando `hc-hold` hasta convertirlo en el blanco #1 de `systemd-oomd`:

- **`logseq` (`npx -y logseq-mcp-server`) — YA RETIRADO:** sigue en `~/.claude.json` y `~/.config/Claude/claude_desktop_config.json` de `cachyos-ofi`. Consume **~185 MB × 7 instancias = ~1.3 GiB** para nada.
- **`anytype` (`npx -y @anyproto/anytype-mcp`):** sigue global en `cachyos-ofi` (y también en `~/.claude.json` de `casa-cachyos`). Consume **~173 MB × 7 = ~1.2 GiB**.
- **`classroom` (`google-classroom-mcp-server`):** consume **~121 MB × 6 = ~725 MB** aunque las sesiones sean de `forja` o `acreditación`.
- **`zotero` (`zotero-mcp`):** consume **~73 MB × 7 = ~510 MB** en todas las sesiones.
- *(En cambio `hindsight-infra`, `hindsight-udgplus` y `hindsight-agentes` son HTTP hacia `sinope:18888` y consumen **0 MB** de procesos locales).*

:::question-multi
¿Qué MCPs stdio globales quitamos de `~/.claude.json` y `claude_desktop_config.json` (con respaldo previo)?

Los que quites del global dejan de multiplicarse en cada sesión de Claude; si alguno lo usas solo en un proyecto puntual (p. ej. `clases` o `zettlr`), se puede mover al `.mcp.json` de esa carpeta.

- [ ] Quitar `logseq` en `cachyos-ofi` (~1.3 GiB menos; Logseq ya está retirado)
- [ ] Quitar `anytype` en `cachyos-ofi` (~1.2 GiB menos en oficina)
- [ ] Quitar `anytype` también en `casa-cachyos` (homologar `~/.claude.json` de casa)
- [ ] Quitar `classroom` del global en `cachyos-ofi` (~725 MB menos; dejarlo solo donde haga falta)
- [ ] Quitar `zotero` del global en `cachyos-ofi` (~510 MB menos; dejarlo solo en proyectos de escritura)

Recommended: Quitar `logseq` en `cachyos-ofi` (~1.3 GiB menos; Logseq ya está retirado)
:::

---

## 2. Servicios ya retirados en tu infraestructura que quedaron zombis en `cachyos-ofi`

Porque `cachyos-ofi` estuvo apagada/offline durante esos retiros, siguen habilitados y corriendo allá:

1. **Mission Control** (desmantelado el `2026-09-30` en sinope): `mission-control-tunnel.service`, `mission-control-runner@claude.service` y `mission-control-runner@codex.service` fallan con `ConnectionResetError` **cada 15 segundos**, ensuciando el journal todo el día.
2. **Collie** (retirado el `2026-10-27` en casa y sinope; estaba anotado en Hindsight como pendiente en `cachyos-ofi`): `collie.service` sigue `enabled` y corriendo, más archivos en `~/.local/share/collie` y `~/.local/bin/collie*`.
3. **Herdr TUI 0.9.5 viejo y `hc` duplicado en `cachyos-ofi`:** `herdr-server.service` + `herdr-server.timer` siguen activos con 14 shells vacíos (`herdr agent list` → `[]`), `~/.local/bin/{hc,herdr-core}` (`0.1.17` del 3-nov) pisa en `PATH` a `/usr/bin/hc` (`0.1.19` de `hc-bin`), y hay **75 `/bin/zsh` huérfanos** colgados de `systemd --user` (~382 MB).

:::question-multi
¿Qué servicios y residuos zombis retiramos en `cachyos-ofi`?

Para Mission Control y Collie se deshabilitan/borran las unidades systemd user y se archiva respaldo igual que en casa.

- [ ] Desmantelar restos de Mission Control en `cachyos-ofi` — `disable --now` y borrar `mission-control-{tunnel,runner@}.service` y `~/.local/bin/mission-control-connector`
- [ ] Completar el retiro pendiente de Collie en `cachyos-ofi` — `disable --now collie.service`, respaldar en `~/.local/share/collie-retiro-2026-11-10.tgz` y limpiar binario/unidad
- [ ] Borrar `~/.local/bin/{hc,herdr-core}` (`0.1.17` viejo) y terminar los 75 `zsh` huérfanos en `cachyos-ofi`
- [ ] Parar y deshabilitar `herdr-server.service` y `herdr-server.timer` (Herdr TUI 0.9.5 viejo, sin agentes) en `cachyos-ofi`

Recommended: Desmantelar restos de Mission Control en `cachyos-ofi` — `disable --now` y borrar `mission-control-{tunnel,runner@}.service` y `~/.local/bin/mission-control-connector`
:::

---

## 3. Aplicaciones pesadas en ejecución y `autostart` en `cachyos-ofi`

Solo entre **Ferdium (6.0 GiB) + Firefox (6.1 GiB) + Chrome Beta (4.4 GiB) + Claude Desktop (1.4 GiB) + hermes-chrome (1.1 GiB) + Zotero (1.7 GiB) + Anytype (0.7 GiB)** se van **21.4 GiB** en un equipo de 32 GiB, dejando muy poco margen para 6–8 agentes y compilaciones de video/cursos.

:::question-multi
¿Qué aplicaciones o demonios cerramos ahora mismo en `cachyos-ofi` para liberar RAM?

No borra datos ni paquetes; solo cierra los procesos (y deshabilita la unidad en el caso de `hermes-chrome` si lo marcas).

- [ ] Cerrar `Ferdium` en `cachyos-ofi` (libera ~6.0 GiB)
- [ ] Cerrar `Claude Desktop` GUI en `cachyos-ofi` (libera ~1.4 GiB; tus sesiones reales están en Herdr CLI)
- [ ] Cerrar `Anytype` GUI en `cachyos-ofi` (libera ~706 MB)
- [ ] Cerrar `Zotero` en `cachyos-ofi` (libera ~1.67 GiB)
- [ ] Deshabilitar y parar `hermes-chrome.service` + `hermes-cdp-tunnel.service` en `cachyos-ofi` (libera ~1.13 GiB; Chrome dedicado a CDP para Hermes)
- [ ] Cerrar `Firefox` en `cachyos-ofi` (libera ~6.1 GiB; manteniendo Chrome Beta) o dejar navegadores intactos si no marcas esta

Recommended: Cerrar `Claude Desktop` GUI en `cachyos-ofi` (libera ~1.4 GiB; tus sesiones reales están en Herdr CLI)
:::

En `~/.config/autostart/` de `cachyos-ofi` arrancan solos en cada inicio: `ferdium.desktop`, `bitwarden.desktop`, `insync.desktop`, `expandrive --autorun.desktop`, `Nextcloud.desktop`, `com.danklinux.dankcalendar.desktop` y `arch-update-tray.desktop` (además de `Fortitray` desde `/etc/xdg/autostart`).

:::question-multi
¿Qué entradas quitamos del arranque automático (`~/.config/autostart/`) en `cachyos-ofi` (moviéndolas a `~/.config/autostart.disabled/`)?

Puedes seguir abriéndolas a mano cuando las ocupes en la oficina, pero no comerán RAM desde el arranque.

- [ ] Quitar `ferdium.desktop` del autostart de oficina (~6 GiB menos de base)
- [ ] Quitar `expandrive --autorun.desktop` del autostart de oficina
- [ ] Quitar `insync.desktop` del autostart de oficina (ya tienes `Nextcloud` y `rclone-gdrive.service`)
- [ ] Quitar `bitwarden.desktop` del autostart de oficina (~350 MB menos; los agentes usan Agent Vault)
- [ ] Ocultar `Fortitray` (`Hidden=true` en `~/.config/autostart/`) en oficina si ya no usas FortiClient local allá

Recommended: Quitar `ferdium.desktop` del autostart de oficina (~6 GiB menos de base)
:::

---

## 4. Blindar `/tmp` (RAM) y auto-reanudación de Herdr

### 4a. Auto-reanudación en caliente (`--auto` de `agent-resume` en `lnk`)

`restore-herdr-agents` solo corre una vez al arrancar Niri tras reiniciar la PC. Con el bloque `--auto` de `herdr-agent-resume` en `.zshrc`, `.bashrc` y `fish` dentro de `lnk`, cada shell de reemplazo en `$HC_TERMINAL_ID` detecta `terminal.pid != label.shell` y relanza sola su sesión (`claude`, `agy` con `--dangerously-skip-permissions`, `codex`, `pi`) tras cualquier caída de `hc-hold`, `hc server restart` o reinicio, incluso sin ventana abierta.

:::question
¿Activamos la auto-reanudación (`--auto`) de `agent-resume` en los shells de `lnk` para casa y oficina?

Usa `claim-guard` para no duplicar con `restore-herdr-agents` ni `Ctrl+Shift+R`, y se puede pausar con `AGENT_RESUME_AUTO=0`.

- [ ] Activar en `.zshrc`, `.bashrc` y `fish` vía `lnk` — commit/push en `lnk` y `lnk pull` en `cachyos-ofi`
- [ ] Activar solo en `.zshrc` vía `lnk` — mismo despliegue tocando únicamente zsh
- [ ] No activar `--auto` — mantener solo `restore-herdr-agents` al arrancar y `Ctrl+Shift+R` manual

Recommended: Activar en `.zshrc`, `.bashrc` y `fish` vía `lnk` — commit/push en `lnk` y `lnk pull` en `cachyos-ofi`
:::

### 4b. Sacar `FI_ESPEJO` de `/tmp` (RAM) en `formacion-integral`

`produccion/cadena.sh:30` y `produccion/video/guion_a_video.py:30` en `~/Projects/udgplus/forja/formacion-integral` apuntan por omisión a `/tmp/fi-cadena` (10 GiB en RAM). El symlink que pusimos hoy desaparece al reiniciar la oficina.

:::question
¿Cambiamos el valor por omisión de `FI_ESPEJO` de `/tmp/fi-cadena` a `/var/tmp/fi-cadena` en `formacion-integral`?

`/var/tmp` vive en el NVMe (239 GiB libres en oficina), fuera de RAM y fuera de Nextcloud.

- [ ] Cambiar a `/var/tmp/fi-cadena` — editar `cadena.sh` y `guion_a_video.py`, commit/push y pull en `cachyos-ofi`
- [ ] No tocar `formacion-integral` — exportar `FI_ESPEJO=/var/tmp/fi-cadena` en `.zshrc` (`lnk`) en su lugar
- [ ] Dejar como está — mantener solo el symlink temporal hasta el próximo reinicio

Recommended: Cambiar a `/var/tmp/fi-cadena` — editar `cadena.sh` y `guion_a_video.py`, commit/push y pull en `cachyos-ofi`
:::

### 4c. Limpiar `/tmp/claude-1000` viejo (2.2 GiB en RAM) y purga a 3 días

En `cachyos-ofi`, `/tmp/claude-1000` retiene **2.9 GiB** en RAM/zram, de los cuales **2.2 GiB** son de un repo retirado el 3 de noviembre (`-home-ruben--local-share-repos-retiro-2026-11-03-udgplus-forja-formacion-integral`).

:::question
¿Borramos esos 2.2 GiB viejos de `/tmp/claude-1000` en `cachyos-ofi` y añadimos purga automática a 3 días con `user-tmpfiles.d` en `lnk`?

`e /tmp/claude-%U/* - - - 3d` solo limpia subdirectorios sin acceso en 3 días; no toca sesiones activas.

- [ ] Borrar los 2.2 GiB retirados + añadir `~/.config/user-tmpfiles.d/claude-tmp.conf` en `lnk` y habilitar `systemd-tmpfiles-clean.timer --user` en casa y oficina
- [ ] Solo borrar ahora los 2.2 GiB retirados en `cachyos-ofi` — sin regla periódica
- [ ] No tocar `/tmp/claude-1000`

Recommended: Borrar los 2.2 GiB retirados + añadir `~/.config/user-tmpfiles.d/claude-tmp.conf` en `lnk` y habilitar `systemd-tmpfiles-clean.timer --user` en casa y oficina
:::

## Respuestas (2026-11-10)

```markdown
# File Feedback

## Answers to your questions

7 of 7 questions answered.

### Q1. ¿Qué MCPs stdio globales quitamos de `~/.claude.json` y `claude_desktop_config.json` (con respaldo previo)? (line 48)
Answer:
- Quitar `logseq` en `cachyos-ofi` (~1.3 GiB menos; Logseq ya está retirado)
- Other: anytype, zotero, classroom si los uso mucho, logseq ya no

### Q2. ¿Qué servicios y residuos zombis retiramos en `cachyos-ofi`? (line 72)
Answer:
- Desmantelar restos de Mission Control en `cachyos-ofi`
- Completar el retiro pendiente de Collie en `cachyos-ofi`
- Borrar `~/.local/bin/{hc,herdr-core}` (`0.1.17` viejo) y terminar los 75 `zsh` huérfanos en `cachyos-ofi`
- Parar y deshabilitar `herdr-server.service` y `herdr-server.timer` (Herdr TUI 0.9.5 viejo, sin agentes) en `cachyos-ofi`

### Q3. ¿Qué aplicaciones o demonios cerramos ahora mismo en `cachyos-ofi` para liberar RAM? (line 91)
Answer:
- Cerrar `Ferdium` en `cachyos-ofi` (libera ~6.0 GiB)
- Cerrar `Claude Desktop` GUI en `cachyos-ofi` (libera ~1.4 GiB; tus sesiones reales están en Herdr CLI)
- Cerrar `Anytype` GUI en `cachyos-ofi` (libera ~706 MB)
- Cerrar `Zotero` en `cachyos-ofi` (libera ~1.67 GiB)
- Cerrar `Firefox` en `cachyos-ofi` (libera ~6.1 GiB; manteniendo Chrome Beta) o dejar navegadores intactos si no marcas esta

### Q4. ¿Qué entradas quitamos del arranque automático (`~/.config/autostart/`) en `cachyos-ofi` (moviéndolas a `~/.config/autostart.disabled/`)? (line 108)
Answer:
- Quitar `expandrive --autorun.desktop` del autostart de oficina
- Ocultar `Fortitray` (`Hidden=true` en `~/.config/autostart/`) en oficina si ya no usas FortiClient local allá
- Other: desinstala todo lo de fortinet en la oficina no es encesario ahí

### Q5. ¿Activamos la auto-reanudación (`--auto`) de `agent-resume` en los shells de `lnk` para casa y oficina? (line 130)
Answer: Activar en `.zshrc`, `.bashrc` y `fish` vía `lnk` (your recommendation)

### Q6. ¿Cambiamos el valor por omisión de `FI_ESPEJO` de `/tmp/fi-cadena` a `/var/tmp/fi-cadena` en `formacion-integral`? (line 146)
Answer: Other: solo si no afeta el trabajo de los cursos de FI

### Q7. ¿Borramos esos 2.2 GiB viejos de `/tmp/claude-1000` en `cachyos-ofi` y añadimos purga automática a 3 días con `user-tmpfiles.d` en `lnk`? (line 162)
Answer: Borrar los 2.2 GiB retirados + añadir `~/.config/user-tmpfiles.d/claude-tmp.conf` en `lnk` y habilitar `systemd-tmpfiles-clean.timer --user` en casa y oficina (your recommendation)

---
```

## Aplicado (2026-11-10)

- **Q1 (MCPs en `cachyos-ofi`):** eliminado únicamente `logseq` de `~/.claude.json` y `~/.config/Claude/claude_desktop_config.json` (respaldos `*.bak-2026-11-10-nologseq`) y terminados los 22 procesos `logseq-mcp-server`. Conservados intactos `anytype`, `zotero`, `classroom`, `open-design` y `hindsight-*`.
- **Q2 (servicios y binarios zombis en `cachyos-ofi`):**
  - Mission Control desmantelado (respaldo `~/.local/share/mission-control-retiro-2026-11-10.tgz`).
  - Retiro de Collie completado en oficina (respaldo `~/.local/share/collie-retiro-2026-11-10.tgz`).
  - Eliminados `~/.local/bin/{hc,herdr-core}` (`0.1.17`, respaldo `~/.local/share/hc-0.1.17-retiro-2026-11-10.tgz`, quedando `/usr/bin/hc` `0.1.19`) y terminados los 45 `zsh` huérfanos reales fuera de `hc-hold-*.service`.
  - Parados y deshabilitados `herdr-server.timer` y `herdr-server.service` (Herdr TUI 0.9.5).
- **Q3 (apps cerradas en `cachyos-ofi`):** cerradas `Ferdium`, `Claude Desktop` GUI, `Anytype` GUI, `Zotero` y `Firefox` (sin tocar `Chrome Beta`, `hermes-chrome`, MCPs activos ni sesiones de `hc`).
- **Q4 (autostart y Fortinet en `cachyos-ofi`):** movido `expandrive --autorun.desktop` a `~/.config/autostart.disabled/`, detenido `fortitraylauncher` y neutralizado con `~/.config/autostart/Fortitray.desktop` (`Hidden=true`). **Pendiente con `sudo`:** desinstalar `forticlient-vpn` y `openfortivpn` (`sudo` en `cachyos-ofi` requiere contraseña local y la identidad `gemini` en Agent Vault solo lee `docencia` y `web-general`).
- **Q5 (`agent-resume --auto`):** añadido el bloque oficial de `herdr-agent-resume` v0.4.1 a `.zshrc`, `.bashrc` y `.config/fish/conf.d/agent-resume.fish` en `lnk`, sincronizado en casa y oficina.
- **Q6 (`FI_ESPEJO` en `formacion-integral`):** actualizado el valor por omisión a `/var/tmp/fi-cadena` en `produccion/cadena.sh`, `produccion/video/guion_a_video.py` y `produccion/video/README.md` (commit `e578583a`, `git pull --ff-only` en `cachyos-ofi`), conservando además `/tmp/fi-cadena -> /var/tmp/fi-cadena` mediante `user-tmpfiles.d` para 100% de compatibilidad con rutas existentes y pipelines activos.
- **Q7 (`/tmp/claude-1000` y `user-tmpfiles.d`):** borrados los 2.2 GiB del repo retirado en `cachyos-ofi`, añadido `~/.config/user-tmpfiles.d/claude-tmp.conf` a `lnk` (`e /tmp/claude-%U/* - - - 3d` + enlace `/tmp/fi-cadena -> /var/tmp/fi-cadena`) y habilitado `systemd-tmpfiles-clean.timer --user` en `casa-cachyos` y `cachyos-ofi`.
- **Resultado en `cachyos-ofi`:** RAM disponible `6.7 GiB → 19 GiB` (usada `12 GiB / 31 GiB`), zram comprimida `14.8 GiB → 2.2 GiB`, `/tmp` (`tmpfs`) `13 GiB (83%) → 821 MiB (6%)`.


