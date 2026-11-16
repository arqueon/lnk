#!/usr/bin/env python3
"""Consulta la cuota del modelo activo de imágenes de Gemini en Antigravity.

Pensado para todos los hosts gestionados con `lnk`:
- Sin dependencias externas fuera de Python 3 estándar (+ `secret-tool` / `notify-send` opcionales).
- Prioriza `arqueonautis@gmail.com` e ignora `ruben.garcia.udg@gmail.com` por defecto;
  si en otro host (p. ej. abdel/jc) no existe `arqueonautis`, usa la sesión activa local.
- Nunca escribe ni expone tokens en argv, archivos temporales, logs ni salida estándar.
"""

from __future__ import annotations

import argparse
import base64
import datetime as dt
import glob
import json
import os
import re
import shutil
import sqlite3
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from typing import Any

DEFAULT_PREFERRED_EMAIL = "arqueonautis@gmail.com"
DEFAULT_IGNORED_EMAILS = "ruben.garcia.udg@gmail.com"
TOKEN_URL = os.environ.get("ANTIGRAVITY_TOKEN_URL", "https://oauth2.googleapis.com/token")
API_BASE = os.environ.get(
    "ANTIGRAVITY_API_BASE_URL", "https://daily-cloudcode-pa.googleapis.com"
).rstrip("/")
USER_AGENT = os.environ.get("ANTIGRAVITY_USER_AGENT", "antigravity/ide/2.1.1 darwin/arm64")

REFRESH_RE = re.compile(rb"1//[A-Za-z0-9_-]{30,}")
NESTED_B64_RE = re.compile(rb"Co[A-Za-z0-9+/=]{40,}")
VERSION_RE = re.compile(r"(\d+)(?:\.(\d+))?")
CLIENT_ID_RE = re.compile(rb"[0-9]{12,13}-[a-z0-9]{32}\.apps\.googleusercontent\.com")
CLIENT_SEC_RE = re.compile(rb"GOCSPX-[A-Za-z0-9_-]{28}")


def _discover_oauth_client_pairs(skip_dms_plugin: bool = False) -> list[tuple[str, str]]:
    """Obtiene el par OAuth público del cliente instalado localmente (sin incrustarlo en git)."""
    env_id = os.environ.get("ANTIGRAVITY_OAUTH_CLIENT_ID", "").strip()
    env_sec = os.environ.get("ANTIGRAVITY_OAUTH_CLIENT_SECRET", "").strip()
    if env_id and env_sec:
        return [(env_id, env_sec)]

    if not skip_dms_plugin:
        cfg = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
        dms_provider = os.path.join(
            cfg, "dms", "plugins", "aiOverviewControl", "providers", "get-provider-usage"
        )
        if os.path.isfile(dms_provider) and os.access(dms_provider, os.R_OK):
            try:
                with open(dms_provider, "rb") as fh:
                    raw = fh.read()
                m_id = re.search(
                    rb"ANTIGRAVITY_OAUTH_CLIENT_ID:-(" + CLIENT_ID_RE.pattern + rb")", raw
                )
                m_sec = re.search(
                    rb"ANTIGRAVITY_OAUTH_CLIENT_SECRET:-(" + CLIENT_SEC_RE.pattern + rb")", raw
                )
                if m_id and m_sec:
                    return [(m_id.group(1).decode("ascii"), m_sec.group(1).decode("ascii"))]
            except Exception:
                pass

    agy_bin = shutil.which("agy")
    if agy_bin and os.path.isfile(agy_bin) and os.access(agy_bin, os.R_OK):
        try:
            with open(agy_bin, "rb") as fh:
                raw = fh.read()
            cids = list(dict.fromkeys(m.decode("ascii") for m in CLIENT_ID_RE.findall(raw)))
            csecs = list(dict.fromkeys(m.decode("ascii") for m in CLIENT_SEC_RE.findall(raw)))
            pairs = [(cid, csec) for cid in cids for csec in csecs]
            if pairs:
                return pairs
        except Exception:
            pass

    raise RuntimeError(
        "No se encontró instalación local de `agy` ni `aiOverviewControl` para obtener el cliente OAuth."
    )


def _b64_decode_loose(raw: bytes | str) -> bytes:
    data = raw.encode("ascii", "ignore") if isinstance(raw, str) else raw
    data = data.strip().replace(b"-", b"+").replace(b"_", b"/")
    pad = (4 - (len(data) % 4)) % 4
    try:
        return base64.b64decode(data + (b"=" * pad), validate=False)
    except Exception:
        return b""


def _extract_refresh_from_json_text(text: str) -> tuple[str, str]:
    try:
        obj = json.loads(text)
    except Exception:
        return "", ""
    if not isinstance(obj, dict):
        return "", ""
    tok_obj = obj.get("token") if isinstance(obj.get("token"), dict) else {}
    rt = (
        obj.get("refresh_token")
        or obj.get("refreshToken")
        or tok_obj.get("refresh_token")
        or tok_obj.get("refreshToken")
        or ""
    )
    email = (obj.get("id_token_email") or "").strip().lower()
    return (rt.strip() if isinstance(rt, str) else ""), email


def _collect_keyring_candidates() -> list[dict[str, Any]]:
    if not shutil.which("secret-tool"):
        return []
    out: list[dict[str, Any]] = []
    # 1. `secret-tool search --all service gemini` recupera todas las sesiones guardadas por agy.
    try:
        proc = subprocess.run(
            ["secret-tool", "search", "--all", "service", "gemini"],
            capture_output=True,
            text=True,
            timeout=3,
            check=False,
        )
        combined = (proc.stdout or "") + "\n" + (proc.stderr or "")
        blocks = re.split(r"(?m)^\[/", combined)
        for blk in blocks:
            secret_val = ""
            modified_val = ""
            for line in blk.splitlines():
                if line.startswith("secret = "):
                    secret_val = line[len("secret = ") :].strip()
                elif line.startswith("modified = "):
                    modified_val = line[len("modified = ") :].strip()
            if secret_val:
                rt, email = _extract_refresh_from_json_text(secret_val)
                if rt:
                    out.append(
                        {
                            "refresh_token": rt,
                            "email_hint": email,
                            "source": "CLI keyring",
                            "modified": modified_val,
                        }
                    )
    except Exception:
        pass

    # 2. Otros nombres de servicio usados por variantes de Antigravity CLI.
    for svc in ("Antigravity CLI", "antigravity-cli", "Antigravity"):
        try:
            proc = subprocess.run(
                ["secret-tool", "lookup", "service", svc],
                capture_output=True,
                text=True,
                timeout=2,
                check=False,
            )
            payload = (proc.stdout or "").strip()
            if payload:
                rt, email = _extract_refresh_from_json_text(payload)
                if rt:
                    out.append(
                        {
                            "refresh_token": rt,
                            "email_hint": email,
                            "source": f"Keyring ({svc})",
                            "modified": "",
                        }
                    )
        except Exception:
            pass
    return out


def _extract_refresh_tokens_from_blob(val: str | bytes) -> list[str]:
    raw = val.encode("utf-8", "ignore") if isinstance(val, str) else val
    found: list[bytes] = []
    found.extend(REFRESH_RE.findall(raw))
    dec1 = _b64_decode_loose(raw)
    if dec1:
        found.extend(REFRESH_RE.findall(dec1))
        printable = re.sub(rb"[^\x20-\x7e]+", b"\n", dec1)
        for nested in NESTED_B64_RE.findall(printable):
            dec2 = _b64_decode_loose(nested)
            if dec2:
                found.extend(REFRESH_RE.findall(dec2))
    seen: set[str] = set()
    res: list[str] = []
    for item in found:
        s = item.decode("ascii", "ignore")
        if s and s not in seen:
            seen.add(s)
            res.append(s)
    return res


def _collect_idedb_candidates() -> list[dict[str, Any]]:
    cfg = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    explicit = [
        os.path.join(cfg, "Antigravity IDE", "User", "globalStorage", "state.vscdb"),
        os.path.join(cfg, "Antigravity", "User", "globalStorage", "state.vscdb"),
    ]
    extra = sorted(glob.glob(os.path.join(cfg, "*ntigravity*", "User", "globalStorage", "state.vscdb")))
    dbs: list[str] = []
    for p in explicit + extra:
        if os.path.isfile(p) and os.access(p, os.R_OK) and p not in dbs:
            dbs.append(p)

    out: list[dict[str, Any]] = []
    query = (
        "SELECT value FROM ItemTable "
        "WHERE key LIKE '%oauth%' OR key LIKE '%Auth%' OR key LIKE '%ync%' OR key LIKE '%jetski%';"
    )
    for db_path in dbs:
        install = os.path.basename(os.path.dirname(os.path.dirname(os.path.dirname(db_path))))
        uri = f"file:{urllib.parse.quote(db_path)}?mode=ro"
        try:
            conn = sqlite3.connect(uri, uri=True, timeout=2.0)
            try:
                rows = conn.execute(query).fetchall()
            finally:
                conn.close()
        except Exception:
            continue
        for (val,) in rows:
            if val is None:
                continue
            for rt in _extract_refresh_tokens_from_blob(val):
                out.append(
                    {
                        "refresh_token": rt,
                        "email_hint": "",
                        "source": install or "Antigravity IDE",
                        "modified": "",
                    }
                )
                break
    return out


def _collect_file_candidates() -> list[dict[str, Any]]:
    cfg = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    paths = [
        os.path.expanduser("~/.gemini/antigravity-cli/antigravity-oauth-token"),
        os.path.join(cfg, "antigravity-cli", "antigravity-oauth-token"),
    ]
    out: list[dict[str, Any]] = []
    for p in paths:
        if os.path.isfile(p) and os.access(p, os.R_OK):
            try:
                with open(p, encoding="utf-8") as fh:
                    rt, email = _extract_refresh_from_json_text(fh.read())
                if rt:
                    out.append(
                        {
                            "refresh_token": rt,
                            "email_hint": email,
                            "source": "CLI file",
                            "modified": "",
                        }
                    )
            except Exception:
                pass
    return out


def _email_from_jwt(id_token: str) -> str:
    if not id_token or "." not in id_token:
        return ""
    parts = id_token.split(".")
    if len(parts) < 2:
        return ""
    raw = _b64_decode_loose(parts[1])
    if not raw:
        return ""
    try:
        payload = json.loads(raw.decode("utf-8", "ignore"))
        return str(payload.get("email") or "").strip().lower()
    except Exception:
        return ""


def _http_json(
    url: str,
    *,
    data: bytes,
    headers: dict[str, str],
    timeout: float = 10.0,
) -> dict[str, Any]:
    req = urllib.request.Request(url, data=data, headers=headers, method="POST")
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        body = resp.read().decode("utf-8", "replace")
    parsed = json.loads(body)
    return parsed if isinstance(parsed, dict) else {}


def _refresh_access_token(
    refresh_token: str, client_pairs: list[tuple[str, str]]
) -> tuple[str, str]:
    last_exc: Exception | None = None
    for client_id, client_secret in client_pairs:
        form = urllib.parse.urlencode(
            {
                "client_id": client_id,
                "client_secret": client_secret,
                "refresh_token": refresh_token,
                "grant_type": "refresh_token",
            }
        ).encode("utf-8")
        try:
            resp = _http_json(
                TOKEN_URL,
                data=form,
                headers={"Content-Type": "application/x-www-form-urlencoded"},
                timeout=8.0,
            )
        except Exception as exc:
            last_exc = exc
            continue
        at = str(resp.get("access_token") or "").strip()
        idt = str(resp.get("id_token") or "").strip()
        if at:
            return at, idt
    if last_exc is not None:
        raise last_exc
    raise RuntimeError("No se obtuvo access_token al refrescar OAuth de Antigravity.")


def _resolve_active_session(preferred_email: str, ignored_emails: set[str]) -> dict[str, str]:
    raw_candidates = (
        _collect_keyring_candidates() + _collect_idedb_candidates() + _collect_file_candidates()
    )
    deduped: list[dict[str, Any]] = []
    seen_rt: set[str] = set()
    for c in raw_candidates:
        rt = c["refresh_token"]
        if rt in seen_rt:
            continue
        seen_rt.add(rt)
        hint = c.get("email_hint", "")
        if hint and hint in ignored_emails:
            continue
        deduped.append(c)

    def sort_key(c: dict[str, Any]) -> tuple[int, str]:
        hint = c.get("email_hint", "")
        if hint == preferred_email:
            prio = 0
        elif hint == "":
            prio = 1
        else:
            prio = 2
        # Mayor fecha de modificación primero dentro de la misma prioridad.
        return (prio, c.get("modified", ""))

    # Ordenar: prio ascendente, fecha descendente.
    deduped.sort(key=lambda c: c.get("modified", ""), reverse=True)
    deduped.sort(key=lambda c: sort_key(c)[0])

    if not deduped:
        raise RuntimeError(
            "No se encontró ninguna sesión activa de Antigravity (IDE o agy CLI) en este host."
        )

    client_pairs = _discover_oauth_client_pairs()
    fallback: dict[str, str] | None = None
    last_err: str | None = None
    for cand in deduped:
        try:
            at, idt = _refresh_access_token(cand["refresh_token"], client_pairs)
        except urllib.error.HTTPError as exc:
            last_err = f"OAuth HTTP {exc.code}"
            continue
        except Exception as exc:
            last_err = str(exc)
            continue

        email = _email_from_jwt(idt) or cand.get("email_hint", "") or "antigravity"
        if email in ignored_emails:
            continue
        session = {
            "access_token": at,
            "email": email,
            "source": cand["source"],
        }
        if email == preferred_email:
            return session
        if fallback is None:
            fallback = session

    if fallback is not None:
        return fallback
    raise RuntimeError(
        f"No hubo sesión utilizable de Antigravity ({last_err or 'cuenta ignorada o expirada'})."
    )


def _fetch_image_model_quota(access_token: str) -> dict[str, Any]:
    common_headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
        "User-Agent": USER_AGENT,
        "X-Goog-Api-Client": "google-cloud-sdk vscode_cloudshelleditor/0.1",
    }
    load_payload = json.dumps(
        {"metadata": {"ideType": 9, "platform": 3, "pluginType": 2}, "mode": 1}
    ).encode("utf-8")
    load_resp = _http_json(
        f"{API_BASE}/v1internal:loadCodeAssist",
        data=load_payload,
        headers=common_headers,
        timeout=10.0,
    )
    proj_raw = load_resp.get("cloudaicompanionProject")
    if isinstance(proj_raw, dict):
        project_id = str(proj_raw.get("id") or "").strip()
    elif isinstance(proj_raw, str):
        project_id = proj_raw.strip()
    else:
        project_id = ""
    if not project_id:
        raise RuntimeError("loadCodeAssist no devolvió cloudaicompanionProject.")

    models_headers = {
        **common_headers,
        "X-Client-Name": "antigravity",
        "X-Client-Version": "2.1.1",
    }
    models_resp = _http_json(
        f"{API_BASE}/v1internal:fetchAvailableModels",
        data=json.dumps({"project": project_id}).encode("utf-8"),
        headers=models_headers,
        timeout=12.0,
    )
    models = models_resp.get("models")
    if not isinstance(models, dict) or not models:
        raise RuntimeError("fetchAvailableModels no devolvió el catálogo de modelos.")

    image_candidates: list[dict[str, Any]] = []
    for mid, mval in models.items():
        if not isinstance(mval, dict):
            continue
        qi = mval.get("quotaInfo")
        if not isinstance(qi, dict):
            continue
        disp = str(mval.get("displayName") or mid).strip()
        haystack = f"{mid} {disp}".lower()
        if "image" not in haystack:
            continue
        m_ver = VERSION_RE.search(disp) or VERSION_RE.search(mid)
        ver_tuple = (int(m_ver.group(1)), int(m_ver.group(2) or 0)) if m_ver else (0, 0)

        reset_time = str(qi.get("resetTime") or "").strip() or None
        if "remainingFraction" in qi and qi["remainingFraction"] is not None:
            rem = max(0.0, min(1.0, float(qi["remainingFraction"])))
        elif reset_time:
            # Protobuf JSON omite remainingFraction cuando llega exactamente a 0.
            rem = 0.0
        else:
            rem = 1.0

        image_candidates.append(
            {
                "id": mid,
                "displayName": disp,
                "version": ver_tuple,
                "remainingFraction": rem,
                "remainingPercent": round(rem * 100.0, 2),
                "usedPercent": round((1.0 - rem) * 100.0, 2),
                "resetsAt": reset_time,
            }
        )

    if not image_candidates:
        raise RuntimeError("No apareció ningún modelo de imagen con cuota en fetchAvailableModels.")

    image_candidates.sort(key=lambda x: (x["version"], x["id"]), reverse=True)
    chosen = image_candidates[0]
    chosen.pop("version", None)
    return chosen


def _format_reset(reset_iso: str | None) -> tuple[str, str]:
    if not reset_iso:
        return "sin ventana activa", ""
    try:
        dt_utc = dt.datetime.fromisoformat(reset_iso.replace("Z", "+00:00"))
        now_local = dt.datetime.now().astimezone()
        dt_local = dt_utc.astimezone(now_local.tzinfo)
        tz_label = dt_local.tzname() or ""
        if dt_local.date() == now_local.date():
            when_str = f"hoy {dt_local.strftime('%H:%M')} {tz_label}".strip()
        else:
            when_str = f"{dt_local.strftime('%Y-%m-%d %H:%M')} {tz_label}".strip()

        delta_sec = int((dt_utc - now_local.astimezone(dt.timezone.utc)).total_seconds())
        if delta_sec <= 0:
            rel_str = "inminente"
        else:
            days, rem = divmod(delta_sec, 86400)
            hours, rem = divmod(rem, 3600)
            mins = rem // 60
            if days > 0:
                rel_str = f"en {days}d {hours}h"
            elif hours > 0:
                rel_str = f"en {hours}h {mins:02d}m"
            else:
                rel_str = f"en {max(1, mins)}m"
        return when_str, rel_str
    except Exception:
        return reset_iso, ""


def _send_notification(title: str, body: str, *, critical: bool = False) -> None:
    if shutil.which("notify-send"):
        urgency = "critical" if critical else "normal"
        subprocess.run(
            [
                "notify-send",
                "-a",
                "Antigravity",
                "-i",
                "image-x-generic",
                "-u",
                urgency,
                "-h",
                "string:x-canonical-private-synchronous:gemini-image-quota",
                title,
                body,
            ],
            check=False,
        )
    elif shutil.which("dms"):
        level = "error" if critical else "info"
        subprocess.run(
            ["dms", "ipc", "call", "toast", level, f"{title} — {body}"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Consulta la cuota del modelo activo de imágenes de Gemini en Antigravity."
    )
    parser.add_argument(
        "--notify",
        action="store_true",
        help="Muestra el resultado como notificación de escritorio (Niri / DMS).",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emite el resultado en JSON.",
    )
    parser.add_argument(
        "--email",
        default=os.environ.get("AGY_IMAGE_QUOTA_EMAIL", DEFAULT_PREFERRED_EMAIL),
        help=f"Cuenta preferida (por defecto: {DEFAULT_PREFERRED_EMAIL}).",
    )
    args = parser.parse_args()

    preferred = (args.email or DEFAULT_PREFERRED_EMAIL).strip().lower()
    ignored = {
        e.strip().lower()
        for e in os.environ.get("AGY_IMAGE_QUOTA_IGNORE_EMAILS", DEFAULT_IGNORED_EMAILS).split(",")
        if e.strip()
    }
    ignored.discard(preferred)

    try:
        session = _resolve_active_session(preferred, ignored)
        quota = _fetch_image_model_quota(session["access_token"])
    except urllib.error.HTTPError as exc:
        msg = f"HTTP {exc.code} al consultar cuota en Antigravity."
        if args.notify:
            _send_notification("Imágenes Gemini · Error", msg, critical=True)
        print(f"error: {msg}", file=sys.stderr)
        return 1
    except Exception as exc:
        msg = str(exc)
        if args.notify:
            _send_notification("Imágenes Gemini · Error", msg, critical=True)
        print(f"error: {msg}", file=sys.stderr)
        return 1

    when_str, rel_str = _format_reset(quota["resetsAt"])
    reset_human = f"{when_str} ({rel_str})" if rel_str else when_str
    rem_pct = quota["remainingPercent"]
    used_pct = quota["usedPercent"]

    payload = {
        "account": session["email"],
        "source": session["source"],
        "modelId": quota["id"],
        "modelName": quota["displayName"],
        "remainingPercent": rem_pct,
        "usedPercent": used_pct,
        "resetsAt": quota["resetsAt"],
        "resetLocal": reset_human,
        "burstLimitNote": "Ráfaga ~30 imágenes / 3h independiente (no expuesta por API)",
    }

    if args.json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        print(f"Modelo:     {payload['modelName']} ({payload['modelId']})")
        print(f"Disponible: {rem_pct:.1f}%  (usado: {used_pct:.1f}%)")
        print(f"Reinicio:   {reset_human}")
        print(f"Cuenta:     {payload['account']} [{payload['source']}]")
        print(f"Nota:       {payload['burstLimitNote']}")

    if args.notify:
        exhausted = rem_pct <= 0.05
        title = (
            "Imágenes Gemini · AGOTADA (0%)"
            if exhausted
            else f"Imágenes Gemini · {rem_pct:.1f}% disponible"
        )
        body = (
            f"{payload['modelName']}\n"
            f"Usado: {used_pct:.1f}% · Reinicio: {reset_human}\n"
            f"Cuenta: {payload['account']}\n"
            f"Ráfaga ~30 img/3h aparte"
        )
        _send_notification(title, body, critical=(rem_pct <= 5.0))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
