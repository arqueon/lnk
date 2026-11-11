// Preload de Bun para Plannotator: inyecta ~/.plannotator/matugen.css
// en todas las superficies web (plan, annotate, review, inbox, shape)
// y actualiza la paleta en vivo cuando Matugen/DMS cambia de fondo.

import { existsSync, readFileSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const execName = (process.execPath || "").split("/").pop() || "";
const arg1 = process.argv?.[1] || "";

if (execName === "plannotator" || arg1.includes("plannotator")) {
  const cssPath = join(homedir(), ".plannotator", "matugen.css");

  const readCss = () => {
    try {
      return existsSync(cssPath) ? readFileSync(cssPath, "utf8") : "";
    } catch {
      return "";
    }
  };

  const getMtime = () => {
    try {
      return existsSync(cssPath) ? String(statSync(cssPath).mtimeMs) : "0";
    } catch {
      return "0";
    }
  };

  const buildInjectSnippet = () => {
    const css = readCss();
    const mtime = getMtime();
    return [
      `<style id="plannotator-matugen-css" data-mtime="${mtime}">${css}</style>`,
      `<script id="plannotator-matugen-live">`,
      `(() => {`,
      `  let last = document.getElementById("plannotator-matugen-css")?.getAttribute("data-mtime") || "0";`,
      `  const poll = async () => {`,
      `    if (document.hidden) return;`,
      `    try {`,
      `      const r = await fetch("/__matugen.css", { method: "HEAD", cache: "no-store" });`,
      `      if (!r.ok) return;`,
      `      const mtime = r.headers.get("x-matugen-mtime") || "";`,
      `      if (mtime && mtime !== last) {`,
      `        last = mtime;`,
      `        const full = await fetch("/__matugen.css?t=" + mtime, { cache: "no-store" });`,
      `        if (!full.ok) return;`,
      `        const css = await full.text();`,
      `        const el = document.getElementById("plannotator-matugen-css");`,
      `        if (el) {`,
      `          el.textContent = css;`,
      `          el.setAttribute("data-mtime", mtime);`,
      `          document.documentElement.setAttribute("data-theme", "matugen-" + mtime);`,
      `        }`,
      `      }`,
      `    } catch {`,
      `      clearInterval(timer);`,
      `    }`,
      `  };`,
      `  const timer = setInterval(poll, 2500);`,
      `  document.addEventListener("visibilitychange", () => { if (!document.hidden) poll(); });`,
      `})();`,
      `</script>`,
    ].join("\n");
  };

  const origServe = Bun.serve.bind(Bun);
  Bun.serve = function (options) {
    if (options && typeof options === "object" && typeof options.fetch === "function") {
      const origFetch = options.fetch;
      options = {
        ...options,
        async fetch(req, server) {
          let url;
          try {
            url = new URL(req.url);
          } catch {
            return origFetch.call(this, req, server);
          }

          if (url.pathname === "/__matugen.css" && (req.method === "GET" || req.method === "HEAD")) {
            const css = readCss();
            const mtime = getMtime();
            return new Response(req.method === "HEAD" ? null : css, {
              status: 200,
              headers: {
                "Content-Type": "text/css; charset=utf-8",
                "Cache-Control": "no-store",
                "X-Matugen-Mtime": mtime,
                "X-Plannotator-Server": "1",
              },
            });
          }

          const isRootHtmlGet =
            url.pathname === "/" &&
            req.method === "GET" &&
            !req.headers.get("upgrade");

          let forwardReq = req;
          if (isRootHtmlGet && (req.headers.has("accept-encoding") || req.headers.has("if-none-match"))) {
            const headers = new Headers(req.headers);
            headers.delete("accept-encoding");
            headers.delete("if-none-match");
            forwardReq = new Request(req.url, {
              method: req.method,
              headers,
            });
          }

          const res = await origFetch.call(this, forwardReq, server);
          if (!isRootHtmlGet || !(res instanceof Response)) return res;

          const ct = res.headers.get("content-type") || "";
          if (!ct.includes("text/html") || res.headers.has("content-encoding")) {
            return res;
          }

          const html = await res.text();
          if (!html.includes("</head>")) {
            return new Response(html, {
              status: res.status,
              statusText: res.statusText,
              headers: res.headers,
            });
          }

          const injected = html.replace("</head>", `${buildInjectSnippet()}\n</head>`);
          const newHeaders = new Headers(res.headers);
          newHeaders.delete("content-length");
          newHeaders.delete("etag");
          return new Response(injected, {
            status: res.status,
            statusText: res.statusText,
            headers: newHeaders,
          });
        },
      };
    }
    return origServe(options);
  };
}
