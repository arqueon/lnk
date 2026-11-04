import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, props, run, theme, home, setShared } from "herdr";

function icon(p, size, color) {
  if (!p?.icon) return null;
  return p.tint
    ? svg(p.icon).size(size).flex_none().text_color(color)
    : image(p.icon).w(size).h(size).flex_none();
}

function folder(cwd) {
  if (!cwd) return "";
  const h = home();
  return cwd === h ? "~" : cwd.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd;
}

export default class DuxPane extends View {
  init() {
    this.hovered = false;
  }

  me() {
    return panes().find((p) => p.pane === props()?.pane);
  }

  button(t, id, iconPath, command, args) {
    return div()
      .id(id)
      .p(3)
      .rounded(4)
      .text_color(t.dim)
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .on_click((_e, cx) => {
        cx.stop_propagation();
        run(command, args);
      })
      .child(svg(iconPath).size(13));
  }

  textBtn(t, id, label, onClick) {
    return div()
      .id(id)
      .px(5)
      .h(18)
      .flex()
      .items_center()
      .rounded(4)
      .text_size(10.5)
      .text_color(t.dim)
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .on_click((_e, cx) => {
        cx.stop_propagation();
        onClick();
      })
      .child(label);
  }

  render() {
    const t = theme();
    const p = this.me();
    if (!p) return div();
    const name =
      ((p.program?.agent || p.program?.shell) && p.program.name) ||
      p.title ||
      p.program?.name ||
      "shell";
    const subTitle =
      p.title && p.title !== name && p.title !== p.program?.name ? p.title : null;
    const pic = icon(p.program, 14, p.focused ? t.accent : t.dim);
    const st = p.status;
    const pane = p.pane;
    const term = p.terminal;
    const tabPanes = panes().filter((x) => x.tab === p.tab).length;

    return h_flex()
      .id(`dux-pane-head-${pane}`)
      .size_full()
      .px(10)
      .gap(7)
      .items_center()
      .bg(p.focused ? t.surface : t.background)
      .border_b(1)
      .border_color(t.border)
      .text_size(12)
      .on_hover((hovered, cx) => {
        this.hovered = hovered;
        cx.notify();
      })
      .on_click(() => run("pane.focus", { pane }))
      .when(Boolean(pic), (el) => el.child(pic))
      .child(
        div()
          .flex_none()
          .truncate()
          .max_w(180)
          .font_medium()
          .text_color(p.focused ? t.foreground : t.muted)
          .child(name)
      )
      .when(Boolean(term), (el) =>
        el.child(
          div()
            .id(`addr-${pane}`)
            .flex_none()
            .px(5)
            .h(17)
            .flex()
            .items_center()
            .rounded(4)
            .bg(t.chrome)
            .border(1)
            .border_color(t.border)
            .text_size(10.5)
            .text_color(t.accent)
            .hover((s) => s.bg(t.hover))
            .on_click((_e, cx) => {
              cx.stop_propagation();
              setShared("dux.triage.target", term);
              run("layout.select", { stack: "panel-body", child: "dux-triage" });
              run("layout.show", { id: "panel" });
            })
            .child(term)
        )
      )
      .when(Boolean(subTitle), (el) =>
        el.child(
          div()
            .flex_none()
            .truncate()
            .max_w(200)
            .text_color(t.muted)
            .child(`· ${subTitle}`)
        )
      )
      .child(
        div()
          .flex_1()
          .truncate()
          .text_color(t.dim)
          .child(folder(p.cwd))
      )
      .when(Boolean(p.branch), (el) =>
        el.child(
          h_flex()
            .flex_none()
            .gap(4)
            .items_center()
            .px(6)
            .h(18)
            .rounded(4)
            .bg(t.chrome)
            .text_size(11)
            .text_color(t.muted)
            .child(svg("mods/workspace-chrome/branch.svg").size(11).text_color(t.accent))
            .child(div().max_w(120).truncate().child(p.branch))
        )
      )
      .when(st === "working", (el) =>
        el.child(
          svg("mods/workspace-chrome/spinner.svg")
            .size(12)
            .flex_none()
            .text_color(t.working)
            .spin(900)
        )
      )
      .when(st === "blocked", (el) =>
        el.child(
          div()
            .id(`blocked-${pane}`)
            .flex_none()
            .px(6)
            .h(18)
            .flex()
            .items_center()
            .rounded(5)
            .bg(t.blocked + "26")
            .text_size(10.5)
            .font_semibold()
            .text_color(t.blocked)
            .on_click((_e, cx) => {
              cx.stop_propagation();
              if (term) setShared("dux.triage.target", term);
              run("layout.select", { stack: "panel-body", child: "dux-triage" });
              run("layout.show", { id: "panel" });
            })
            .child("Te espera")
        )
      )
      .when(st === "done", (el) =>
        el.child(div().size(7).flex_none().rounded(4).bg(t.done))
      )
      .when(this.hovered, (el) =>
        el
          .child(
            this.button(t, `ph-r-${pane}`, "mods/pane/split-right.svg", "pane.split", {
              direction: "right",
              pane,
            })
          )
          .child(
            this.button(t, `ph-d-${pane}`, "mods/pane/split-down.svg", "pane.split", {
              direction: "down",
              pane,
            })
          )
          .when(Boolean(term && tabPanes > 1), (b) =>
            b.child(
              this.textBtn(t, `ph-park-${pane}`, "Park", () =>
                run("terminal.park", { terminal: term })
              )
            )
          )
          .child(
            this.button(
              t,
              `ph-z-${pane}`,
              `mods/pane/${p.zoomed ? "unzoom" : "zoom"}.svg`,
              "pane.zoom",
              { pane }
            )
          )
          .child(
            this.button(t, `ph-x-${pane}`, "mods/pane/close.svg", "pane.close", { pane })
          )
      );
  }
}
