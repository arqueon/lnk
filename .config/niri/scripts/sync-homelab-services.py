#!/usr/bin/env python3
"""
sync-homelab-services.py
Sincroniza los servicios de Sinope y NAS-BTB desde Uptime Kuma y Cloudflare Tunnel.
Genera catálogos TSV y JSON estructurados para los lanzadores de Niri / Fuzzel.
"""

import os
import sys
import re
import json
import subprocess
from pathlib import Path

# Directorios de destino
NIRI_DIR = Path.home() / ".config" / "niri"
LNK_NIRI_DIR = Path.home() / ".config" / "lnk" / ".config" / "niri"

DATA_DIR = NIRI_DIR / "data"
LNK_DATA_DIR = LNK_NIRI_DIR / "data"

DATA_DIR.mkdir(parents=True, exist_ok=True)
LNK_DATA_DIR.mkdir(parents=True, exist_ok=True)

# Mapeo de metadatos conocidos, alias, categorías e iconos
SERVICE_METADATA = {
    # Sinope - Productividad & Colaboración
    "nextcloud.arqueonautis.org": {
        "name": "Nextcloud",
        "category": "Productividad",
        "desc": "Archivos, sincronización y oficina",
        "icon": "󰒋",
        "server": "sinope",
        "order": 10
    },
    "muros.arqueonautis.org": {
        "name": "Digipad",
        "category": "Docencia",
        "desc": "Muros y pizarras colaborativas",
        "icon": "󰽉",
        "server": "sinope",
        "order": 12
    },
    "tasks.arqueonautis.org": {
        "name": "Vikunja Tasks",
        "category": "Productividad",
        "desc": "Gestión de tareas y proyectos",
        "icon": "󰊢",
        "server": "sinope",
        "order": 15
    },
    "mealie.arqueonautis.org": {
        "name": "Mealie",
        "category": "Hogar",
        "desc": "Gestión de recetas y planificador de menú",
        "icon": "󰄛",
        "server": "sinope",
        "order": 20
    },
    "cal.arqueonautis.org": {
        "name": "Cal.com",
        "category": "Productividad",
        "desc": "Agendamiento de citas y calendario",
        "icon": "󰊓",
        "server": "sinope",
        "order": 22
    },
    "linkwarden.arqueonautis.org": {
        "name": "Linkwarden",
        "category": "Productividad",
        "desc": "Archivo y guardado de enlaces web",
        "icon": "󰌹",
        "server": "sinope",
        "order": 25
    },
    "links.arqueonautis.org": {
        "name": "LinkBreeze",
        "category": "Productividad",
        "desc": "Páginas públicas de enlaces",
        "icon": "󰛄",
        "server": "sinope",
        "order": 26
    },
    "wallabag.arqueonautis.org": {
        "name": "Wallabag",
        "category": "Productividad",
        "desc": "Lectura diferida (read-it-later)",
        "icon": "󰈙",
        "server": "sinope",
        "order": 28
    },
    "miniflux.arqueonautis.org": {
        "name": "Miniflux",
        "category": "Productividad",
        "desc": "Lector RSS minimalista",
        "icon": "󰑈",
        "server": "sinope",
        "order": 30
    },
    "pdf.arqueonautis.org": {
        "name": "BentoPDF",
        "category": "Utilidades",
        "desc": "Herramientas de manipulación de PDF",
        "icon": "󰈦",
        "server": "sinope",
        "order": 32
    },
    "survey.arqueonautis.org": {
        "name": "LimeSurvey",
        "category": "Docencia",
        "desc": "Encuestas y recolección de datos",
        "icon": "󰕥",
        "server": "sinope",
        "order": 34
    },
    "particify.arqueonautis.org": {
        "name": "Particify",
        "category": "Docencia",
        "desc": "Participación interactiva en clases",
        "icon": "󰙴",
        "server": "sinope",
        "order": 36
    },
    "claper.arqueonautis.org": {
        "name": "Claper",
        "category": "Docencia",
        "desc": "Presentaciones interactivas",
        "icon": "󰍡",
        "server": "sinope",
        "order": 38
    },
    "moodle-dev.arqueonautis.org": {
        "name": "Moodle Dev",
        "category": "Docencia",
        "desc": "Entorno de desarrollo de microcursos",
        "icon": "󰏤",
        "server": "sinope",
        "order": 40
    },
    "actual.arqueonautis.org": {
        "name": "Actual Budget",
        "category": "Finanzas",
        "desc": "Presupuesto personal basado en sobres",
        "icon": "󰄲",
        "server": "sinope",
        "order": 42
    },
    "ha.arqueonautis.org": {
        "name": "Home Assistant",
        "category": "Hogar",
        "desc": "Automatización y control del hogar",
        "icon": "󰟀",
        "server": "sinope",
        "order": 45
    },

    # Sinope - Media & Streaming
    "jellyfin.arqueonautis.org": {
        "name": "Jellyfin",
        "category": "Media",
        "desc": "Servidor de cine y series",
        "icon": "󰕼",
        "server": "sinope",
        "order": 50
    },
    "immich.arqueonautis.org": {
        "name": "Immich",
        "category": "Media",
        "desc": "Gestor y galería fotográfica",
        "icon": "󰵂",
        "server": "sinope",
        "order": 52
    },
    "navidrome.arqueonautis.org": {
        "name": "Navidrome",
        "category": "Media",
        "desc": "Servidor de streaming de música",
        "icon": "󰋋",
        "server": "sinope",
        "order": 54
    },
    "seerr.arqueonautis.org": {
        "name": "Seerr (Overseerr)",
        "category": "Media",
        "desc": "Solicitudes y descubrimiento multimedia",
        "icon": "󰄛",
        "server": "sinope",
        "order": 56
    },
    "foreseerr.arqueonautis.org": {
        "name": "Foreseerr",
        "category": "Media",
        "desc": "Descubrimiento multimedia alternativo",
        "icon": "󰄛",
        "server": "sinope",
        "order": 57
    },
    "sonarr.arqueonautis.org": {
        "name": "Sonarr",
        "category": "Media Arr",
        "desc": "Gestión automática de series",
        "icon": "󰚗",
        "server": "sinope",
        "order": 60
    },
    "radarr.arqueonautis.org": {
        "name": "Radarr",
        "category": "Media Arr",
        "desc": "Gestión automática de películas",
        "icon": "󰚗",
        "server": "sinope",
        "order": 62
    },
    "lidarr.arqueonautis.org": {
        "name": "Lidarr",
        "category": "Media Arr",
        "desc": "Gestión automática de música",
        "icon": "󰚗",
        "server": "sinope",
        "order": 64
    },
    "bazarr.arqueonautis.org": {
        "name": "Bazarr",
        "category": "Media Arr",
        "desc": "Gestión de subtítulos",
        "icon": "󰚗",
        "server": "sinope",
        "order": 66
    },
    "profilarr.arqueonautis.org": {
        "name": "Profilarr",
        "category": "Media Arr",
        "desc": "Sincronización de perfiles TRaSH",
        "icon": "󰚗",
        "server": "sinope",
        "order": 68
    },
    "sinope.tailf70cf8.ts.net:8282": {
        "name": "Decypharr",
        "url": "https://sinope.tailf70cf8.ts.net:8282/",
        "category": "Media Arr",
        "desc": "Gestor de colas y puente Debrid para *arr",
        "icon": "󰚗",
        "server": "sinope",
        "order": 69
    },
    "tautulli.arqueonautis.org": {
        "name": "Tautulli",
        "category": "Media",
        "desc": "Estadísticas y monitoreo Plex/Jellyfin",
        "icon": "󰄛",
        "server": "sinope",
        "order": 70
    },
    "aurral.arqueonautis.org": {
        "name": "Aurral",
        "category": "Media",
        "desc": "Recomendaciones musicales Last.fm para Lidarr",
        "icon": "󰋋",
        "server": "sinope",
        "order": 72
    },
    "qbittorrent.arqueonautis.org": {
        "name": "qBittorrent Sinope",
        "category": "Descargas",
        "desc": "Cliente BitTorrent en Sinope",
        "icon": "󰒍",
        "server": "sinope",
        "order": 75
    },
    "sabnzbd.arqueonautis.org": {
        "name": "SABnzbd",
        "category": "Descargas",
        "desc": "Cliente de descargas Usenet",
        "icon": "󰇚",
        "server": "sinope",
        "order": 77
    },
    "slskd.arqueonautis.org": {
        "name": "slskd (Soulseek)",
        "category": "Descargas",
        "desc": "Cliente Soulseek P2P vía VPS",
        "icon": "󰇚",
        "server": "sinope",
        "order": 79
    },

    # Sinope - Infraestructura & Automatización
    "kuma.arqueonautis.org": {
        "name": "Uptime Kuma",
        "category": "Monitoreo",
        "desc": "Disponibilidad sintética del Homelab",
        "icon": "󱓞",
        "server": "sinope",
        "order": 80
    },
    "coolify.arqueonautis.org": {
        "name": "Coolify",
        "category": "Infraestructura",
        "desc": "Panel de aplicaciones y despliegues",
        "icon": "󰒋",
        "server": "sinope",
        "order": 82
    },
    "adguard.arqueonautis.org": {
        "name": "AdGuard Home",
        "category": "Infraestructura",
        "desc": "DNS filtrante y control de red",
        "icon": "󰒋",
        "server": "sinope",
        "order": 84
    },
    "vault.arqueonautis.org": {
        "name": "Vaultwarden (Arqueonautis)",
        "category": "Seguridad",
        "desc": "Gestor de contraseñas personal",
        "icon": "󰌋",
        "server": "sinope",
        "order": 86
    },
    "automation.arqueonautis.org": {
        "name": "n8n Sinope",
        "category": "Automatización",
        "desc": "Flujos y automatizaciones del servidor",
        "icon": "󰦨",
        "server": "sinope",
        "order": 88
    },
    "notify.arqueonautis.org": {
        "name": "ntfy Sinope",
        "category": "Monitoreo",
        "desc": "Servidor de notificaciones push",
        "icon": "󰂚",
        "server": "sinope",
        "order": 90
    },
    "changes.arqueonautis.org": {
        "name": "changedetection.io",
        "category": "Monitoreo",
        "desc": "Vigilancia de cambios en páginas web",
        "icon": "󰛐",
        "server": "sinope",
        "order": 92
    },
    "aio.arqueonautis.org": {
        "name": "Nextcloud AIO Panel",
        "category": "Infraestructura",
        "desc": "Panel de administración Nextcloud AIO",
        "icon": "󰒋",
        "server": "sinope",
        "order": 94
    },
    "mc.arqueonautis.org": {
        "name": "Mission Control",
        "category": "Agentes",
        "desc": "Panel de control y despacho de Hermes",
        "icon": "󰚩",
        "server": "sinope",
        "order": 96
    },
    "hermes.arqueonautis.org": {
        "name": "Hermes Web",
        "category": "Agentes",
        "desc": "Interfaz web de Hermes Agent",
        "icon": "󰚩",
        "server": "sinope",
        "order": 98
    },
    "tablero.analisissustanciaspsicoactivas.org": {
        "name": "Tablero Sustancias",
        "category": "Docencia",
        "desc": "Tablero Shiny de análisis de sustancias",
        "icon": "󰆼",
        "server": "sinope",
        "order": 99
    },

    # NAS-BTB (Barbies Testeadoras)
    "barbiestesteadoras.org": {
        "name": "Barbies Testeadoras Web",
        "category": "Público",
        "desc": "Sitio web principal BTB",
        "icon": "󰖟",
        "server": "nas-btb",
        "order": 10
    },
    "hacker.barbiestesteadoras.org": {
        "name": "Barbie Hacker",
        "category": "Público",
        "desc": "Portal de divulgación y guías BTB",
        "icon": "󰖟",
        "server": "nas-btb",
        "order": 12
    },
    "grist.barbiestesteadoras.org": {
        "name": "Grist BTB",
        "category": "Productividad",
        "desc": "Bases de datos colaborativas y tablas",
        "icon": "󰆼",
        "server": "nas-btb",
        "order": 15
    },
    "nextcloud.barbiestesteadoras.org": {
        "name": "Nextcloud BTB",
        "category": "Productividad",
        "desc": "Archivos compartidos y trabajo en equipo",
        "icon": "󰒋",
        "server": "nas-btb",
        "order": 20
    },
    "collabora.barbiestesteadoras.org": {
        "name": "Collabora Online BTB",
        "category": "Productividad",
        "desc": "Edición ofimática en navegador",
        "icon": "󰈙",
        "server": "nas-btb",
        "order": 22
    },
    "cursos.barbiestesteadoras.org": {
        "name": "Moodle BTB",
        "category": "Docencia",
        "desc": "Plataforma de cursos y talleres",
        "icon": "󰏤",
        "server": "nas-btb",
        "order": 25
    },
    "vivo.barbiestesteadoras.org": {
        "name": "Particify BTB",
        "category": "Docencia",
        "desc": "Participación interactiva en vivo",
        "icon": "󰙴",
        "server": "nas-btb",
        "order": 28
    },
    "pdf.barbiestesteadoras.org": {
        "name": "BentoPDF BTB",
        "category": "Utilidades",
        "desc": "Herramientas de documentos PDF",
        "icon": "󰈦",
        "server": "nas-btb",
        "order": 30
    },
    "vault.barbiestesteadoras.org": {
        "name": "Vaultwarden BTB",
        "category": "Seguridad",
        "desc": "Gestor de contraseñas de organización",
        "icon": "󰌋",
        "server": "nas-btb",
        "order": 35
    },
    "automatizaciones.barbiestesteadoras.org": {
        "name": "n8n BTB",
        "category": "Automatización",
        "desc": "Automatizaciones e integraciones BTB",
        "icon": "󰦨",
        "server": "nas-btb",
        "order": 40
    },
    "notify.barbiestesteadoras.org": {
        "name": "ntfy BTB",
        "category": "Monitoreo",
        "desc": "Notificaciones centinela de NAS-BTB",
        "icon": "󰂚",
        "server": "nas-btb",
        "order": 42
    },
    "media.barbiestesteadoras.org": {
        "name": "Jellyfin BTB",
        "category": "Media",
        "desc": "Videoteca de medios de BTB",
        "icon": "󰕼",
        "server": "nas-btb",
        "order": 50
    },
    "fotos.barbiestesteadoras.org": {
        "name": "Immich BTB",
        "category": "Media",
        "desc": "Galería y respaldo de fotos BTB",
        "icon": "󰵂",
        "server": "nas-btb",
        "order": 52
    },
    "formularios.barbiestesteadoras.org": {
        "name": "Formularios BTB",
        "category": "Público",
        "desc": "Formularios de registro e ingreso",
        "icon": "󰕥",
        "server": "nas-btb",
        "order": 60
    },
    "finanzas.barbiestesteadoras.org": {
        "name": "Portal Financiero BTB",
        "category": "Finanzas",
        "desc": "Gestión financiera institucional",
        "icon": "󰄲",
        "server": "nas-btb",
        "order": 65
    },
    "transparencia.barbiestesteadoras.org": {
        "name": "Transparencia BTB",
        "category": "Público",
        "desc": "Información pública y rendición de cuentas",
        "icon": "󰖟",
        "server": "nas-btb",
        "order": 70
    },
    "docs.barbiestesteadoras.org": {
        "name": "Documentación BTB",
        "category": "Documentación",
        "desc": "Guías y base de conocimiento",
        "icon": "󰈙",
        "server": "nas-btb",
        "order": 72
    },
    "ficha.barbiestesteadoras.org": {
        "name": "Ficha BTB",
        "category": "Público",
        "desc": "Fichas técnicas y registro",
        "icon": "󰈙",
        "server": "nas-btb",
        "order": 74
    },
    "informes.barbiestesteadoras.org": {
        "name": "Informes BTB",
        "category": "Documentación",
        "desc": "Informes de actividades y resultados",
        "icon": "󰈙",
        "server": "nas-btb",
        "order": 76
    },
    "muestreo.barbiestesteadoras.org": {
        "name": "Muestreo BTB",
        "category": "Docencia",
        "desc": "Registro de muestras y análisis",
        "icon": "󰆼",
        "server": "nas-btb",
        "order": 78
    },
    "100.95.27.14": {
        "name": "TrueNAS SCALE UI",
        "category": "Infraestructura",
        "desc": "Panel de administración TrueNAS (Tailscale)",
        "icon": "󰒋",
        "server": "nas-btb",
        "order": 80
    }
}


def query_uptime_kuma():
    """Consulta monitores activos en la base SQLite de Uptime Kuma en sinope."""
    cmd = [
        "ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=4", "sinope",
        "sqlite3 /home/sinope/uptime-kuma/data/kuma.db "
        "\"SELECT m.id, m.name, m.type, m.url, m.hostname, m.port, m.parent, p.name "
        "FROM monitor m LEFT JOIN monitor p ON m.parent = p.id WHERE m.active = 1;\""
    ]
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=8)
        if res.returncode != 0:
            print(f"[WARN] Error al consultar Uptime Kuma: {res.stderr.strip()}", file=sys.stderr)
            return []
        monitors = []
        for line in res.stdout.strip().split("\n"):
            if not line.strip():
                continue
            parts = line.split("|")
            if len(parts) >= 8:
                mid, name, mtype, url, host, port, parent_id, parent_name = parts[:8]
                monitors.append({
                    "id": mid,
                    "name": name,
                    "type": mtype,
                    "url": url,
                    "host": host,
                    "port": port,
                    "parent_id": parent_id,
                    "parent_name": parent_name
                })
        return monitors
    except Exception as e:
        print(f"[WARN] Excepción al consultar Kuma: {e}", file=sys.stderr)
        return []


def query_cloudflared_ingress():
    """Consulta la configuración de túneles Cloudflare en Sinope para detectar servicios nuevos."""
    cmd = [
        "ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=4", "sinope",
        "cat /etc/cloudflared/config.yml 2>/dev/null || cat /home/sinope/.cloudflared/config.yml 2>/dev/null"
    ]
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=8)
        if res.returncode != 0:
            return []
        hostnames = []
        for line in res.stdout.splitlines():
            line_str = line.strip()
            if line_str.startswith("- hostname:"):
                host = line_str.split(":", 1)[1].strip()
                if host and host not in hostnames:
                    hostnames.append(host)
        return hostnames
    except Exception as e:
        print(f"[WARN] Excepción al consultar Cloudflare tunnel: {e}", file=sys.stderr)
        return []


def build_catalogs():
    kuma_monitors = query_uptime_kuma()
    cf_hostnames = query_cloudflared_ingress()

    sinope_services = {}
    nasbtb_services = {}

    # 1. Procesar monitores de Kuma
    for m in kuma_monitors:
        # Filtrar monitores internos de tipo push o ping que no sean páginas web de usuario
        if m["type"] in ("push", "ping", "dns", "group"):
            continue
        
        raw_url = m["url"] or ""
        if not raw_url and m["host"] and m["port"]:
            raw_url = f"http://{m['host']}:{m['port']}"
        elif not raw_url and m["host"]:
            raw_url = f"http://{m['host']}"

        if not raw_url:
            continue

        # Normalizar URL para búsqueda en metadatos
        clean_host = raw_url.replace("https://", "").replace("http://", "").split("/")[0]

        # Determinar servidor
        is_btb = (
            "barbiestesteadoras" in raw_url or 
            m["parent_id"] == "55" or 
            m["parent_name"] == "NAS BTB" or
            "NAS BTB" in m["name"] or
            "100.95.27.14" in raw_url
        )
        server = "nas-btb" if is_btb else "sinope"

        meta = SERVICE_METADATA.get(clean_host, {})
        
        # Limpieza de nombre si viene de Kuma (ej. "NAS BTB · Fotos Immich" -> "Immich")
        clean_name = meta.get("name")
        if not clean_name:
            clean_name = m["name"].replace("NAS BTB · ", "").strip()

        # Si la URL apunta a endpoints de salud (/alive, /health, /status.php, /api/server/ping), limpiar a la raíz del servicio
        user_url = raw_url
        if any(suffix in user_url for suffix in ["/alive", "/health", "/status.php", "/api/server/ping", "/v1/health", "/healthz", "/hosting/discovery"]):
            user_url = re.sub(r"/(alive|health|status\.php|api/server/ping|v1/health|healthz|hosting/discovery)$", "", user_url)
            if not user_url.endswith("/"):
                user_url += "/"

        entry = {
            "name": clean_name,
            "url": user_url,
            "category": meta.get("category", "General"),
            "desc": meta.get("desc", m["name"]),
            "icon": meta.get("icon", "󰒋"),
            "order": meta.get("order", 100),
            "server": server
        }

        if server == "sinope":
            sinope_services[clean_host] = entry
        else:
            nasbtb_services[clean_host] = entry

    # 2. Agregar o actualizar con Cloudflare Tunnel Ingress (para servicios nuevos como Digipad)
    for host in cf_hostnames:
        if host in ("arqueonautis.org", "crm.arqueonautis.org", "barbies.arqueonautis.org", "hacker.arqueonautis.org", "formularios.arqueonautis.org"):
            # Omitir alias obsoletos o redirigidos
            continue
        
        url = f"https://{host}"
        meta = SERVICE_METADATA.get(host, {})
        server = meta.get("server", "sinope" if "arqueonautis" in host or "analisis" in host else "nas-btb")
        
        target_dict = sinope_services if server == "sinope" else nasbtb_services

        if host not in target_dict:
            # Nuevo servicio detectado en Cloudflare!
            clean_name = meta.get("name", host.split(".")[0].capitalize())
            target_dict[host] = {
                "name": clean_name,
                "url": url,
                "category": meta.get("category", "Servicios"),
                "desc": meta.get("desc", f"Servicio en {host}"),
                "icon": meta.get("icon", "󰒋"),
                "order": meta.get("order", 90),
                "server": server
            }

    # 3. Incluir entradas manuales del diccionario que no estuvieran en Kuma ni CF
    for host, meta in SERVICE_METADATA.items():
        server = meta["server"]
        target_dict = sinope_services if server == "sinope" else nasbtb_services
        if host not in target_dict:
            url = meta.get("url") or (f"https://{host}/" if (":" in host or host.startswith("100.")) else f"https://{host}")
            target_dict[host] = {
                "name": meta["name"],
                "url": url,
                "category": meta["category"],
                "desc": meta["desc"],
                "icon": meta["icon"],
                "order": meta.get("order", 100),
                "server": server
            }

    # Ordenar por order y nombre
    sinope_list = sorted(sinope_services.values(), key=lambda x: (x["order"], x["name"].lower()))
    nasbtb_list = sorted(nasbtb_services.values(), key=lambda x: (x["order"], x["name"].lower()))

    return sinope_list, nasbtb_list


def write_outputs(sinope_list, nasbtb_list):
    # Escribir JSON global
    homelab_data = {
        "updated": "2026-08-24",
        "sinope": sinope_list,
        "nas_btb": nasbtb_list
    }
    
    for base in [DATA_DIR, LNK_DATA_DIR]:
        with open(base / "homelab-services.json", "w", encoding="utf-8") as f:
            json.dump(homelab_data, f, indent=2, ensure_ascii=False)

        # Escribir TSVs optimizados para fuzzel (icono, nombre, url, categoría, descripción)
        with open(base / "sinope-services.tsv", "w", encoding="utf-8") as f:
            for item in sinope_list:
                f.write(f"{item['icon']}\t{item['name']}\t{item['url']}\t{item['category']}\t{item['desc']}\n")

        with open(base / "nas-btb-services.tsv", "w", encoding="utf-8") as f:
            for item in nasbtb_list:
                f.write(f"{item['icon']}\t{item['name']}\t{item['url']}\t{item['category']}\t{item['desc']}\n")

    print(f"✓ Catálogos generados con éxito:")
    print(f"  - Sinope: {len(sinope_list)} servicios registrados")
    print(f"  - NAS-BTB: {len(nasbtb_list)} servicios registrados")


if __name__ == "__main__":
    sinope_list, nasbtb_list = build_catalogs()
    write_outputs(sinope_list, nasbtb_list)
