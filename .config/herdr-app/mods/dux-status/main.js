import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import {
  spaces,
  agents,
  machines,
  theme,
  run,
  window,
  keys,
  home,
  appHome,
  readTextFile,
  writeTextFile,
  watchFolder,
  setShared,
} from "herdr";

function buildMatugenTheme(dms) {
  const mode = dms.mode || "dark";
  const c = (dms.colors && (dms.colors[mode] || dms.colors.dark)) || {};
  const d16 = dms.dank16 || {};
  const ansi = [];
  for (let i = 0; i < 16; i++) {
    const entry = d16[`color${i}`] || {};
    ansi.push(entry[mode] || entry.default || "#888888");
  }
  return {
    background: c.surface || ansi[0],
    foreground: c.on_surface || ansi[15],
    selection: c.primary_container || "#004b6f",
    cursor: c.primary || ansi[4],
    ansi,
    colors: {
      canvas: c.surface_container_lowest || "#0b0f12",
      background: c.surface || ansi[0],
      chrome: c.surface_container_low || "#181c20",
      surface: c.surface_container || "#1c2024",
      raised: c.surface_container_high || "#262a2e",
      popover: c.surface_container_highest || "#313539",
      hover: c.surface_bright || "#363a3e",
      selected: c.primary_container || "#004b6f",
      border: c.outline_variant || "#41484d",
      input: c.outline_variant || "#41484d",
      foreground: c.on_surface || ansi[15],
      muted: c.on_surface_variant || "#c1c7ce",
      dim: c.outline || "#8b9198",
      accent: c.primary || ansi[4],
      accent_foreground: c.on_primary || "#00344e",
      solid: c.primary || ansi[4],
      solid_foreground: c.on_primary || "#00344e",
      selection: c.primary_container || "#004b6f",
      working: c.primary || ansi[12],
      blocked: c.error || ansi[1],
      done: ansi[2] || "#52e0c4",
      idle: c.secondary || ansi[6],
      unknown: c.outline || ansi[8],
    },
  };
}

export default class DuxStatus extends View {
  init(_props, cx) {
    this.dmsMode = "dark";
    cx.spawn(async (cx) => {
      await this.syncDmsColors(cx);
      const dmsDir = `${home()}/.cache/DankMaterialShell`;
      for (;;) {
        try {
          await watchFolder(dmsDir);
          await this.syncDmsColors(cx);
        } catch (_e) {
          break;
        }
      }
    });
  }

  async syncDmsColors(cx) {
    try {
      const dmsPath = `${home()}/.cache/DankMaterialShell/dms-colors.json`;
      const raw = await readTextFile(dmsPath);
      if (!raw) return;
      const dms = JSON.parse(raw);
      this.dmsMode = dms.mode || "dark";
      const nextObj = buildMatugenTheme(dms);
      const nextText = JSON.stringify(nextObj, null, 2) + "\n";
      const outPath = `${appHome()}/themes/matugen.json`;
      const current = await readTextFile(outPath);
      if (current !== nextText) {
        await writeTextFile(outPath, nextText, current);
      }
      cx.notify();
    } catch (_e) {
      // Ignore transient parse errors while DMS writes the file
    }
  }

  hint() {
    const mac = window()?.platform === "macos";
    const mod = {
      cmd: mac ? "⌘" : "Ctrl+",
      ctrl: mac ? "⌃" : "Ctrl+",
      shift: mac ? "⇧" : "Shift+",
      alt: mac ? "⌥" : "Alt+",
      option: mac ? "⌥" : "Alt+",
    };
    const b = keys().find((k) => k.section === "global" && k.action === "app.palette");
    const parts =
      b && b.keys.endsWith("--") ? [...b.keys.slice(0, -2).split("-"), "-"] : b?.keys.split("-");
    const key = parts && parts.map((p) => mod[p.toLowerCase()] ?? p.toUpperCase()).join("");
    return key ? `${key} comandos` : "comandos";
  }

  render() {
    const t = theme();
    const space = spaces().find((s) => s.active);
    const list = agents();
    const blockedList = list.filter((a) => a.status === "blocked");
    const workingList = list.filter((a) => a.status === "working");
    const doneList = list.filter((a) => a.status === "done");
    const mList = machines();
    const remoteReady = mList.filter((m) => m.name !== null && m.layout === "ready").length;

    const label = (icon, text) =>
      h_flex()
        .gap(5)
        .items_center()
        .child(svg(`mods/workspace-chrome/${icon}.svg`).size(12.5).text_color(t.accent))
        .child(text);

    return h_flex()
      .size_full()
      .px(12)
      .gap(14)
      .items_center()
      .bg(t.chrome)
      .border_t(1)
      .border_color(t.border)
      .text_size(11.5)
      .text_color(t.muted)
      .child(
        label(
          space?.machine ? "server" : "monitor",
          space?.machine
            ? `${space.machine}`
            : remoteReady > 0
              ? `Local · +${remoteReady} rem`
              : "Local"
        )
      )
      .when(Boolean(space?.branch), (el) =>
        el.child(
          div()
            .id("status-branch")
            .px(6)
            .h(20)
            .flex()
            .items_center()
            .rounded(4)
            .hover((s) => s.bg(t.hover).text_color(t.foreground))
            .on_click(() => {
              run("layout.select", { stack: "panel-body", child: "changes" });
              run("layout.show", { id: "panel" });
            })
            .child(label("branch", space.branch))
        )
      )
      .child(
        h_flex()
          .gap(8)
          .items_center()
          .when(blockedList.length > 0, (el) =>
            el.child(
              h_flex()
                .id("status-blocked")
                .px(7)
                .h(20)
                .gap(5)
                .items_center()
                .rounded(4)
                .bg(t.blocked + "26")
                .text_color(t.blocked)
                .font_semibold()
                .hover((s) => s.bg(t.blocked + "40"))
                .on_click(() => {
                  const target = blockedList[0];
                  if (target) {
                    setShared("dux.triage.target", target.address);
                    run("agent.focus", { terminal: target.address });
                  }
                  run("layout.select", { stack: "panel-body", child: "dux-triage" });
                  run("layout.show", { id: "panel" });
                })
                .child(div().size(6).rounded(3).bg(t.blocked))
                .child(`${blockedList.length} te espera${blockedList.length === 1 ? "" : "n"}`)
            )
          )
          .when(workingList.length > 0, (el) =>
            el.child(
              h_flex()
                .gap(5)
                .items_center()
                .text_color(t.working)
                .child(
                  svg("mods/workspace-chrome/spinner.svg")
                    .size(11)
                    .text_color(t.working)
                    .spin(900)
                )
                .child(`${workingList.length} activos`)
            )
          )
          .when(doneList.length > 0, (el) =>
            el.child(
              h_flex()
                .id("status-done")
                .px(6)
                .h(20)
                .gap(5)
                .items_center()
                .rounded(4)
                .text_color(t.done)
                .hover((s) => s.bg(t.hover))
                .on_click(() => {
                  const target = doneList[0];
                  if (target) run("agent.focus", { terminal: target.address });
                })
                .child(div().size(6).rounded(3).bg(t.done))
                .child(`${doneList.length} listos`)
            )
          )
          .child(
            h_flex()
              .gap(5)
              .items_center()
              .text_color(t.dim)
              .child(`${list.length} agentes`)
          )
      )
      .child(div().flex_1())
      .child(
        div()
          .id("status-dms")
          .px(6)
          .h(20)
          .flex()
          .items_center()
          .rounded(4)
          .text_color(t.dim)
          .hover((s) => s.bg(t.hover).text_color(t.foreground))
          .on_click((_e, cx) => {
            this.syncDmsColors(cx);
          })
          .child(`DMS ${this.dmsMode}`)
      )
      .child(
        div()
          .id("status-triage")
          .px(6)
          .h(20)
          .flex()
          .items_center()
          .rounded(4)
          .text_color(t.muted)
          .hover((s) => s.bg(t.hover).text_color(t.foreground))
          .on_click(() => {
            run("layout.select", { stack: "panel-body", child: "dux-triage" });
            run("layout.toggle", { id: "panel" });
          })
          .child("Alt+D Triage")
      )
      .child(
        div()
          .id("palette")
          .px(6)
          .h(20)
          .flex()
          .items_center()
          .rounded(4)
          .text_color(t.dim)
          .hover((s) => s.bg(t.hover).text_color(t.foreground))
          .on_click(() => run("app.palette"))
          .child(this.hint())
      );
  }
}
