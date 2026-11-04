import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex, InputState, Input, Scrollbar } from "gpui-base";
import {
  agents,
  spaces,
  focused,
  hc,
  exec,
  run,
  openOverlay,
  theme,
  shared,
  setShared,
  nextCommand,
} from "herdr";

export default class DuxTriage extends View {
  init(_props, cx) {
    this.text = "";
    this.screen = "";
    this.reposOut = "";
    this.sending = false;
    this.statusMsg = "";
    this.lastAddr = null;

    this.input = InputState.new({
      value: "",
      placeholder: "Escribe respuesta o instrucción (Enter para enviar)…",
    });
    this.input.on("change", (_e, cx) => {
      this.text = this.input.value();
      cx.notify();
    });
    this.input.on("submit", (_e, cx) => this.sendReply(this.text, cx));
    this.inputFocused = false;
    this.input.on("focus", (_e, cx) => {
      this.inputFocused = true;
      cx.notify();
    });
    this.input.on("blur", (_e, cx) => {
      this.inputFocused = false;
      cx.notify();
    });

    this.refreshScreen(cx);
    cx.timer.every(3000, (cx) => this.refreshScreen(cx));

    cx.spawn(async (cx) => {
      for (;;) {
        try {
          const cmd = await nextCommand();
          if (cmd === "toggle") {
            run("layout.select", { stack: "panel-body", child: "dux-triage" });
            run("layout.toggle", { id: "panel" });
          } else if (cmd === "next-blocked") {
            const b = agents().filter((a) => a.status === "blocked");
            if (b.length > 0) {
              setShared("dux.triage.target", b[0].address);
              run("agent.focus", { terminal: b[0].address });
              run("layout.select", { stack: "panel-body", child: "dux-triage" });
              run("layout.show", { id: "panel" });
            }
          }
          this.refreshScreen(cx);
        } catch (_e) {
          break;
        }
      }
    });
  }

  targetAgent() {
    const list = agents();
    const sharedTarget = shared("dux.triage.target");
    if (sharedTarget) {
      const found = list.find((a) => a.address === sharedTarget);
      if (found) return found;
    }
    const f = focused();
    if (f?.terminal) {
      const found = list.find((a) => a.address === f.terminal);
      if (found) return found;
    }
    const blocked = list.find((a) => a.status === "blocked");
    if (blocked) return blocked;
    return list[0] || null;
  }

  refreshScreen(cx) {
    const a = this.targetAgent();
    if (!a) {
      if (this.screen !== "") {
        this.screen = "";
        cx.notify();
      }
      return;
    }
    const addr = a.address;
    cx.spawn(async (cx) => {
      try {
        const res = await hc(["read", addr]);
        if (res.code === 0) {
          const lines = (res.stdout || "").split("\n");
          const tail = lines.slice(-36).join("\n").trim();
          if (tail !== this.screen || this.lastAddr !== addr) {
            this.screen = tail;
            this.lastAddr = addr;
            cx.notify();
          }
        }
      } catch (_e) {
        // Ignore transient read error
      }
    });
  }

  sendReply(msg, cx) {
    const a = this.targetAgent();
    if (!a || this.sending) return;
    const payload = msg ?? this.text;
    this.sending = true;
    this.statusMsg = "Enviando…";
    cx.notify();

    cx.spawn(async (cx) => {
      try {
        const args = ["send"];
        if (a.status === "blocked") args.push("--force");
        args.push(a.address, payload);
        const res = await hc(args);
        if (res.code === 0) {
          this.statusMsg = `Enviado a ${a.address}`;
          if (msg === this.text) {
            this.text = "";
            this.input.set_value("");
          }
        } else {
          this.statusMsg = res.stderr || "Error al enviar";
        }
      } catch (e) {
        this.statusMsg = String(e);
      }
      this.sending = false;
      this.refreshScreen(cx);
      cx.notify();
    });
  }

  interruptAgent(cx) {
    const a = this.targetAgent();
    if (!a) return;
    cx.spawn(async (cx) => {
      try {
        await hc(["interrupt", a.address]);
        this.statusMsg = `Interrumpido ${a.address}`;
      } catch (e) {
        this.statusMsg = String(e);
      }
      this.refreshScreen(cx);
      cx.notify();
    });
  }

  checkRepos(cx) {
    this.reposOut = "Consultando repos estado…";
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const r = await exec("sh", ["-lc", "repos estado 2>&1 | head -n 18"]);
        this.reposOut = (r.stdout || r.stderr || "Sin salida").trim();
      } catch (e) {
        this.reposOut = String(e);
      }
      cx.notify();
    });
  }

  render(cx) {
    const t = theme();
    const list = agents();
    const blocked = list.filter((a) => a.status === "blocked");
    const others = list.filter((a) => a.status !== "blocked");
    const ordered = [...blocked, ...others];
    const current = this.targetAgent();
    const space = spaces().find((s) => s.active);

    const statusBadge = (st) => {
      const color =
        st === "blocked"
          ? t.blocked
          : st === "working"
            ? t.working
            : st === "done"
              ? t.done
              : t.dim;
      const label =
        st === "blocked"
          ? "Te espera"
          : st === "working"
            ? "Activo"
            : st === "done"
              ? "Listo"
              : "Idle";
      return div()
        .px(6)
        .h(18)
        .flex()
        .items_center()
        .rounded(4)
        .bg(color + "26")
        .text_size(10.5)
        .font_semibold()
        .text_color(color)
        .child(label);
    };

    const agentRow = (a) => {
      const selected = current?.address === a.address;
      const pic = a.program?.icon;
      return h_flex()
        .id(`triage-ag-${a.address}`)
        .h(32)
        .px(8)
        .gap(7)
        .items_center()
        .rounded(6)
        .bg(selected ? t.selected : a.status === "blocked" ? t.blocked + "14" : t.surface)
        .border(1)
        .border_color(selected ? t.accent : a.status === "blocked" ? t.blocked + "55" : t.border)
        .hover((s) => s.bg(t.hover))
        .on_click(() => {
          setShared("dux.triage.target", a.address);
          this.refreshScreen(cx);
        })
        .when(Boolean(pic), (el) =>
          el.child(
            a.program.tint
              ? svg(pic).size(13).text_color(selected ? t.accent : t.muted)
              : image(pic).size(13)
          )
        )
        .child(
          div()
            .px(4)
            .h(16)
            .flex()
            .items_center()
            .rounded(3)
            .bg(t.chrome)
            .text_size(10)
            .text_color(t.accent)
            .child(a.address)
        )
        .child(
          div()
            .flex_1()
            .truncate()
            .text_size(12)
            .text_color(t.foreground)
            .child(`${a.space_name} · ${a.title || a.program?.name || "agent"}`)
        )
        .child(statusBadge(a.status))
        .child(
          div()
            .id(`triage-go-${a.address}`)
            .px(5)
            .h(18)
            .flex()
            .items_center()
            .rounded(4)
            .bg(t.chrome)
            .text_size(10.5)
            .text_color(t.muted)
            .hover((s) => s.bg(t.accent).text_color(t.accent_foreground))
            .on_click((_e, cx) => {
              cx.stop_propagation();
              run("agent.focus", { terminal: a.address });
            })
            .child("Ir →")
        );
    };

    const actionChip = (id, label, primary, onClick) =>
      div()
        .id(id)
        .px(8)
        .h(26)
        .flex()
        .items_center()
        .rounded(6)
        .border(1)
        .border_color(primary ? t.accent : t.border)
        .bg(primary ? t.accent : t.raised)
        .text_size(11.5)
        .font_medium()
        .text_color(primary ? t.accent_foreground : t.foreground)
        .hover((s) => s.opacity(0.88))
        .on_click(onClick)
        .child(label);

    return v_flex()
      .size_full()
      .p(10)
      .gap(8)
      .rounded(10)
      .border(1)
      .border_color(t.border)
      .bg(t.surface)
      .text_color(t.foreground)
      .child(
        h_flex()
          .items_center()
          .justify_between()
          .pb(4)
          .border_b(1)
          .border_color(t.border)
          .child(
            h_flex()
              .gap(6)
              .items_center()
              .child(div().text_size(13).font_semibold().child("Dux Triage · Flota"))
              .when(blocked.length > 0, (el) =>
                el.child(
                  div()
                    .px(6)
                    .h(18)
                    .flex()
                    .items_center()
                    .rounded(4)
                    .bg(t.blocked + "26")
                    .text_size(11)
                    .font_semibold()
                    .text_color(t.blocked)
                    .child(`${blocked.length} bloqueado${blocked.length === 1 ? "" : "s"}`)
                )
              )
          )
          .child(
            div()
              .id("triage-refresh")
              .px(6)
              .h(22)
              .flex()
              .items_center()
              .rounded(4)
              .text_size(11)
              .text_color(t.dim)
              .hover((s) => s.bg(t.hover).text_color(t.foreground))
              .on_click(() => this.refreshScreen(cx))
              .child("Actualizar")
          )
      )
      .child(
        div()
          .relative()
          .h(136)
          .child(
            v_flex()
              .id("triage-agent-list")
              .size_full()
              .gap(4)
              .overflow_y_scroll()
              .children(ordered.map(agentRow))
              .when(ordered.length === 0, (el) =>
                el.child(
                  div()
                    .p(8)
                    .text_size(12)
                    .text_color(t.dim)
                    .child("No hay agentes activos en esta sesión.")
                )
              )
          )
          .child(Scrollbar.vertical("triage-agent-list").absolute().inset_0())
      )
      .when(Boolean(current), (el) =>
        el
          .child(
            h_flex()
              .items_center()
              .justify_between()
              .pt(2)
              .child(
                div()
                  .text_size(11.5)
                  .font_medium()
                  .text_color(t.muted)
                  .child(`Pantalla en vivo · ${current.address} (${current.space_name})`)
              )
              .when(Boolean(this.statusMsg), (s) =>
                s.child(div().text_size(11).text_color(t.accent).child(this.statusMsg))
              )
          )
          .child(
            div()
              .relative()
              .flex_1()
              .min_h(110)
              .rounded(7)
              .border(1)
              .border_color(t.border)
              .bg(t.background)
              .p(8)
              .child(
                v_flex()
                  .id("triage-screen-scroll")
                  .size_full()
                  .overflow_y_scroll()
                  .child(
                    div()
                      .text_size(11)
                      .text_color(t.foreground)
                      .child(this.screen || "(Pantalla vacía)")
                  )
              )
              .child(Scrollbar.vertical("triage-screen-scroll").absolute().inset_0())
          )
          .child(
            Input.new(this.input)
              .h(32)
              .px(10)
              .items_center()
              .rounded(6)
              .border(1)
              .border_color(this.inputFocused ? t.accent : t.input)
              .bg(t.background)
              .text_size(12)
              .text_color(t.foreground)
          )
          .child(
            h_flex()
              .gap(6)
              .flex_wrap()
              .child(
                actionChip("tr-send", "Enviar", true, () => this.sendReply(this.text, cx))
              )
              .child(
                actionChip("tr-yes", "Aprobar (y↵)", false, () => this.sendReply("y", cx))
              )
              .child(
                actionChip("tr-enter", "Enter (↵)", false, () => this.sendReply("", cx))
              )
              .child(
                actionChip("tr-int", "Ctrl+C", false, () => this.interruptAgent(cx))
              )
              .child(
                actionChip("tr-focus", "Enfocar panel", false, () =>
                  run("agent.focus", { terminal: current.address })
                )
              )
          )
      )
      .child(
        v_flex()
          .pt(6)
          .gap(6)
          .border_t(1)
          .border_color(t.border)
          .child(
            div().text_size(11).font_semibold().text_color(t.dim).child("Acciones de proyecto")
          )
          .child(
            h_flex()
              .gap(6)
              .flex_wrap()
              .child(
                actionChip("act-lg", "Lazygit", false, () =>
                  run("terminal.open", { argv: ["lazygit"], place: "right" })
                )
              )
              .child(
                actionChip("act-wt", "Worktree…", false, () =>
                  openOverlay({
                    mod: "worktree",
                    kind: "dialog",
                    width: 440,
                    height: 220,
                    props: { space: space?.id, action: "new" },
                  })
                )
              )
              .child(
                actionChip("act-repos", "repos estado", false, () => this.checkRepos(cx))
              )
              .child(
                actionChip("act-hs", "Hindsight", false, () =>
                  run("terminal.open", {
                    argv: ["zsh", "-ic", "hs todos 'pendientes recientes' --reflect; exec zsh"],
                    place: "right",
                  })
                )
              )
          )
          .when(Boolean(this.reposOut), (el) =>
            el.child(
              div()
                .p(6)
                .rounded(5)
                .bg(t.background)
                .border(1)
                .border_color(t.border)
                .text_size(10.5)
                .text_color(t.muted)
                .child(this.reposOut)
            )
          )
      );
  }
}
