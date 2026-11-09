import re, sys, pathlib, shutil
sec = pathlib.Path(sys.argv[1]).read_text().rstrip() + "\n"
block = "<!-- revision-local:start v=1 -->\n" + sec + "<!-- revision-local:end -->"
AB = r"<!-- sdocs-agent-block:start.*?<!-- sdocs-agent-block:end -->\n?"
DL = r"<!-- sdoc-desktop-local:start.*?<!-- sdoc-desktop-local:end -->"
for f in sys.argv[2:]:
    p = pathlib.Path(f).expanduser()
    if not p.is_file(): print("missing", f); continue
    t0 = t = p.read_text()
    has_rev = "revision-local:start" in t
    if re.search(DL, t, re.S):
        t = re.sub(DL, "" if has_rev else (lambda m: block), t, flags=re.S); has_rev = True
    if re.search(AB, t, re.S):
        t = re.sub(AB, "" if has_rev else (lambda m: block + "\n"), t, count=1, flags=re.S); has_rev = True
        t = re.sub(AB, "", t, flags=re.S)
    if not has_rev:
        t = t.rstrip() + "\n\n" + block + "\n"
    t = t.replace("SmallDocs duraderos de proyectos → `retain` en Hindsight", "Expedientes de revisión duraderos (`.revision/`) → `retain` en Hindsight")
    t = re.sub(r"\n{3,}", "\n\n", t)
    if t != t0:
        shutil.copy2(p, str(p) + ".bak-smalldocs-2026-11-08"); p.write_text(t); print("OK", f)
    else: print("sin cambios", f)
