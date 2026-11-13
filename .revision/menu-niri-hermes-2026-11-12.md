# Reducir el menú Niri de Hermes (`Mod+Shift+F10`) a lo indispensable (2026-11-12)

Nada se ha modificado todavía. Este expediente reúne el estado real de las 12 entradas actuales del menú en [`launch-hermes.sh`](file:///home/ruben/.config/lnk/.config/niri/scripts/launch-hermes.sh) y [`hermes-sinope`](file:///home/ruben/.config/lnk/.config/niri/scripts/hermes-sinope) para decidir qué dejamos, qué quitamos y qué corregimos.

> **Alcance compartido (`lnk`):** [`launch-hermes.sh`](file:///home/ruben/.config/lnk/.config/niri/scripts/launch-hermes.sh) y [`hermes-sinope`](file:///home/ruben/.config/lnk/.config/niri/scripts/hermes-sinope) viven en `~/.config/lnk/.lnk`, así que el menú aplica a todas las máquinas con tus dotfiles (casa, oficina, laptop, star-lite y `abdel-home`, que selecciona automáticamente `hermes-abdel@sinope`).

---

## Inventario actual (12 entradas) vs. estado real hoy

Comprobado hoy en `hermes@100.107.89.3` (Hermes Agent `v0.23.0`) y en esta estación (`casa-cachyos`):

| # | Etiqueta actual en el menú | Subcomando | Estado real hoy (2026-11-12) | Diagnóstico |
|---|---|---|---|---|
| 1 | `WebUI comunitaria` | `webui` | En Rubén abre `https://hermes.arqueonautis.org/` (desde el 6-nov apunta al **Webapp oficial** del gateway en `:9120`, no a `hermes-webui :8787`). En Abdel abre túnel SSH a `hermes-webui :8788` (aunque su Webapp `:9121` también escucha). | **Dejar**, corrigiendo la etiqueta (y decidir si Abdel pasa a `:9121`). |
| 2 | `Desktop oficial` | `desktop` | Instalado (`/usr/bin/hermes-desktop`, `hermes-agent-desktop 0.22.5-1`). Usa *Connect via SSH* con perfil aislado. | **Dejar** (solo aparece si está instalado). |
| 3 | `TUI oficial persistente (tmux)` | `tui` | Abre terminal + SSH a `hermes-remote-tui` en sesión tmux `hermes-tui` / `hermina-tui`. | **Dejar** (entrada ligera de consola diaria). |
| 4 | `Hermes Gate (sesiones tmux)` | `gate` | Instalado en `~/Projects/utils/hermes-gate`. TUI local en Python para gestionar múltiples sesiones tmux por SSH. | **Opcional:** redundante si solo usas una TUI, útil si manejas varias sesiones tmux. |
| 5 | `Dashboard oficial · administración (bajo demanda)` | `dashboard` | `hermes-dashboard-lab.service` está **enabled y active** permanentemente en `:9119` (lo usa la app móvil Android `ai.nousresearch.hermes.mobile`). Solo se abre por túnel SSH local `:9119`. | **Opcional / revisar etiqueta:** ya no es «bajo demanda»; útil solo para admin puntual (config, cron, logs) si no lo cubres con Webapp/Desktop. |
| 6 | `Laboratorio · Hermes Workspace` | `workspace` | `hermes-workspace-lab.service` (`:13300`): `disabled`, `inactive`. No existe en `hermes-abdel`. | **Quitar del menú** (laboratorio viejo). |
| 7 | `Laboratorio · Hermes UI PWA` | `pwa` | `hermes-ui-pwa-lab.service` (`:19120`): `disabled`, `inactive`. No existe en `hermes-abdel`. | **Quitar del menú** (laboratorio viejo). |
| 8 | `Laboratorio · Open WebUI (pesada)` | `open-webui` | `open-webui-hermes-lab.service` (`:18080`): `disabled`, `inactive` (~2 GB, ~1 min en arrancar). | **Quitar del menú** (laboratorio pesado). |
| 9 | `Laboratorio · Hermes One (comunitaria)` | `hermes-one` | **No instalado** localmente (`Hermes One: no instalado`); hoy ya queda oculto en el menú. | **Quitar del menú** (y su lógica condicional si ya no la usarás). |
| 10 | `Estado de interfaces` | `status` | Abre terminal con el estado de servicios remotos, túneles locales y clientes locales (`simplex-chat.service` marca `inactive`). | **Opcional:** diagnóstico rápido útil en `Mod+Shift+F10` o solo en CLI (`hermes-sinope status`). |
| 11 | `Preparar tmux remoto (UTF-8 + portapapeles)` | `tmux-setup` | Copia `hermes-remote-tmux.conf` a Sinope. Es configuración de una sola vez. | **Quitar del menú** (conservar solo en CLI `hermes-sinope tmux-setup`). |
| 12 | `Detener laboratorios y túneles` | `stop-labs` | **Trampa activa:** además de cerrar túneles, ejecuta `systemctl --user stop hermes-dashboard-lab.service ...`, lo que **apaga el Dashboard que usa la app móvil Android**. | **Quitar del menú** (y corregir `hermes-sinope` para que nunca detenga `hermes-dashboard-lab.service`). |

---

## Propuesta mínima recomendada (3 o 4 entradas)

Si reducimos el menú `Mod+Shift+F10` a lo indispensable para el uso diario:

1. **Webapp oficial (navegador)** — entrada principal en Chrome (`https://hermes.arqueonautis.org/` para Rubén).
2. **Desktop oficial** — app nativa por SSH (cuando esté instalada).
3. **TUI oficial (tmux)** — sesión persistente en terminal.
4. *(Opcional)* **Dashboard oficial (admin)** y/o **Estado de interfaces** (o **Hermes Gate** si sigues usando varias sesiones tmux).

Con 3–4 entradas el selector de `fuzzel` deja de ser un panel de laboratorio y se vuelve un lanzador inmediato.

---

## Decisiones

:::question-multi
¿Qué entradas principales y de diagnóstico conservamos en el menú `Mod+Shift+F10`?

Marca todas las que quieras mantener visibles en `launch-hermes.sh`. Las no marcadas se quitan del menú.

- [ ] Webapp / WebUI en navegador (`webui`) — entrada web principal
- [ ] Desktop oficial (`desktop`) — cliente nativo por SSH (si está instalado)
- [ ] TUI oficial persistente en tmux (`tui`) — sesión de terminal persistente
- [ ] Hermes Gate (`gate`) — gestor multi-sesión tmux por SSH
- [ ] Dashboard oficial (`dashboard`) — panel admin `:9119` por túnel SSH (quitando «bajo demanda»)
- [ ] Estado de interfaces (`status`) — ventana rápida de diagnóstico remoto/local

Recommended: Webapp / WebUI en navegador (`webui`) — entrada web principal
:::

:::question-multi
¿Qué entradas de laboratorio y mantenimiento quitamos del menú `Mod+Shift+F10`?

Marca todas las que quieres retirar del selector gráfico. En `stop-labs`, además conviene corregir `hermes-sinope` para que nunca detenga `hermes-dashboard-lab.service` (necesario para la app Android).

- [ ] Quitar `Laboratorio · Hermes Workspace` (`workspace`)
- [ ] Quitar `Laboratorio · Hermes UI PWA` (`pwa`)
- [ ] Quitar `Laboratorio · Open WebUI (pesada)` (`open-webui`)
- [ ] Quitar `Laboratorio · Hermes One (comunitaria)` (`hermes-one`)
- [ ] Quitar `Preparar tmux remoto` (`tmux-setup`) del menú (dejarlo en CLI)
- [ ] Quitar `Detener laboratorios y túneles` (`stop-labs`) del menú

Recommended: Quitar `Laboratorio · Hermes Workspace` (`workspace`)
:::

:::question
¿Qué hacemos en el backend CLI (`hermes-sinope` y `launch-hermes-one.sh`) con los laboratorios retirados del menú?

Solo limpiar `launch-hermes.sh` mantiene intactos los comandos de terminal por si alguna vez quieres lanzar algo a mano; limpiar también `hermes-sinope` reduce el script y sus túneles asociados. En ambos casos conviene sacar `hermes-dashboard-lab.service` de `stop-labs` para no cortar la app Android.

- [ ] Solo limpiar el menú (`launch-hermes.sh`) y proteger `hermes-dashboard-lab` en `stop-labs` — conserva los subcomandos en `hermes-sinope` CLI por si acaso
- [ ] Limpiar menú y quitar también `workspace`, `pwa`, `open-webui`, `hermes-one` de `hermes-sinope` (y `launch-hermes-one.sh`) — deja `hermes-sinope` también mínimo, conservando `webui`, `desktop`, `tui`, `gate`, `dashboard`, `tmux-setup`, `status` y un `stop-tunnels` seguro
- [ ] Dejar los subcomandos CLI sin tocar y solo editar `launch-hermes.sh`

Recommended: Solo limpiar el menú (`launch-hermes.sh`) y proteger `hermes-dashboard-lab` en `stop-labs` — conserva los subcomandos en `hermes-sinope` CLI por si acaso
:::

:::question
¿Cómo etiquetamos y enrutamos la entrada web (`webui`)?

Para Rubén, `https://hermes.arqueonautis.org/` apunta desde el 6 de noviembre al Webapp oficial (`127.0.0.1:9120`), no a la WebUI comunitaria (`:8787`). Para Abdel (`hermes-abdel`), tanto la WebUI comunitaria (`:8788`) como el Webapp oficial (`:9121`) están escuchando en Sinope.

- [ ] Renombrar a «Webapp oficial» en Rubén (`https://hermes.arqueonautis.org/`) y dejar túnel `:8788` («WebUI») en Abdel — sin tocar la experiencia actual de Abdel
- [ ] Renombrar a «Webapp oficial» en ambos y apuntar el túnel de Abdel al Webapp oficial (`:9121`) en lugar de `:8788` — unifica a ambos perfiles en el Webapp oficial v0.23.0
- [ ] Mantener «WebUI» genérico sin cambiar puertos

Recommended: Renombrar a «Webapp oficial» en Rubén (`https://hermes.arqueonautis.org/`) y dejar túnel `:8788` («WebUI») en Abdel — sin tocar la experiencia actual de Abdel
:::

## Respuestas (2026-11-12)

```text
# File Feedback

## Answers to your questions

4 of 4 questions answered.

### Q1. ¿Qué entradas principales y de diagnóstico conservamos en el menú `Mod+Shift+F10`? (line 46)
Answer:
- Webapp / WebUI en navegador (`webui`)
- Desktop oficial (`desktop`)
- TUI oficial persistente en tmux (`tui`)

### Q2. ¿Qué entradas de laboratorio y mantenimiento quitamos del menú `Mod+Shift+F10`? (line 61)
Answer:
- Quitar `Laboratorio · Hermes Workspace` (`workspace`)
- Quitar `Laboratorio · Hermes UI PWA` (`pwa`)
- Quitar `Laboratorio · Open WebUI (pesada)` (`open-webui`)
- Quitar `Laboratorio · Hermes One (comunitaria)` (`hermes-one`)
- Quitar `Preparar tmux remoto` (`tmux-setup`) del menú (dejarlo en CLI)
- Quitar `Detener laboratorios y túneles` (`stop-labs`) del menú
Note: desinstala las apps que removamos del sistema

### Q3. ¿Qué hacemos en el backend CLI (`hermes-sinope` y `launch-hermes-one.sh`) con los laboratorios retirados del menú? (line 76)
Answer: Limpiar menú y quitar también `workspace`, `pwa`, `open-webui`, `hermes-one` de `hermes-sinope` (y `launch-hermes-one.sh`)

### Q4. ¿Cómo etiquetamos y enrutamos la entrada web (`webui`)? (line 88)
Answer: Renombrar a «Webapp oficial» en ambos y apuntar el túnel de Abdel al Webapp oficial (`:9121`) en lugar de `:8788`

---
```
