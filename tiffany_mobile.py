#!/usr/bin/env python3
import os, re, json, glob, subprocess, secrets
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs

ROOT = os.path.expanduser("~/tiffany")
PIN_FILE = os.path.expanduser("~/.config/tiffany/mobile_pin.txt")
os.makedirs(os.path.dirname(PIN_FILE), exist_ok=True)

if not os.path.exists(PIN_FILE):
    with open(PIN_FILE, "w") as f:
        f.write(str(secrets.randbelow(9000) + 1000))

def get_pin():
    return open(PIN_FILE).read().strip()

def get_stats():
    try:
        temps = []
        for z in glob.glob("/sys/class/thermal/thermal_zone*/temp"):
            try:
                v = int(open(z).read().strip())
                if 10000 < v < 120000:
                    temps.append(v / 1000.0)
            except Exception:
                pass
        temp = f"{max(temps):.1f}°C" if temps else "N/A"
    except Exception:
        temp = "N/A"
    try:
        lines = subprocess.check_output(["free", "-m"]).decode().splitlines()
        parts = lines[1].split()
        tot, used = int(parts[1]), int(parts[2])
        ram = f"{used*100//tot}% ({used}/{tot} Mo)"
    except Exception:
        ram = "N/A"
    return {"temp": temp, "ram": ram}

def lister_outils():
    boutons = []
    vus = set()
    for dossier in ("plugins", "actions_terminal"):
        for f in sorted(glob.glob(os.path.join(ROOT, dossier, "*.sh"))):
            base = os.path.basename(f)
            if base.endswith(".off"):
                continue
            # Nettoie le prefixe numerique (ex: 02_analyse.sh -> analyse)
            nom = re.sub(r"^\d+[a-z]?_", "", base[:-3]).replace("_", " ").strip()
            if nom and nom not in vus:
                vus.add(nom)
                boutons.append((nom.capitalize(), nom))
    return boutons

def run_cmd(ordre):
    ordre = ordre.strip()
    if not ordre:
        return "Ordre vide."
    for script in ("interpreteur_universel.sh", "tiffany_actions.sh"):
        sp = os.path.join(ROOT, script)
        if os.path.exists(sp):
            try:
                out = subprocess.check_output(["bash", sp, ordre], stderr=subprocess.STDOUT, timeout=30).decode("utf-8", errors="ignore").strip()
                return out[-1200:] if out else f"✅ Ordre '{ordre}' exécuté."
            except subprocess.TimeoutExpired:
                return f"⏳ '{ordre}' lancé en arrière-plan sur le PC."
            except Exception as e:
                return f"Exécuté ({e})"
    return f"Ordre reçu : {ordre}"

def build_html():
    outils_html = "".join(
        f'<button onclick="send(\'{cmd}\')">{label}</button>'
        for label, cmd in lister_outils()
    )
    return f"""<!DOCTYPE html>
<html lang="fr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">
<meta name="theme-color" content="#12121a">
<title>🌹 Tiffany AI-OS Mobile</title>
<style>
body{{font-family:system-ui,sans-serif;background:#12121a;color:#f3f4f6;margin:0;padding:14px;padding-bottom:40px;}}
h1{{font-size:1.25rem;text-align:center;color:#fb7185;margin:4px 0 10px;}}
h2{{font-size:.95rem;color:#9ca3af;margin:0 0 8px;text-transform:uppercase;letter-spacing:.04em;}}
.card{{background:#1e1e2e;border-radius:14px;padding:12px;margin-bottom:12px;box-shadow:0 4px 12px rgba(0,0,0,.35);}}
.stats{{display:flex;justify-content:space-around;font-weight:bold;font-size:1rem;}}
.grid{{display:grid;grid-template-columns:1fr 1fr;gap:8px;}}
.grid3{{display:grid;grid-template-columns:1fr 1fr 1fr;gap:6px;}}
button{{background:#2e2e42;color:#fff;border:none;border-radius:10px;padding:11px 8px;font-size:.88rem;font-weight:600;cursor:pointer;word-break:break-word;}}
button:active{{background:#fb7185;color:#12121a;}}
.stop{{background:#991b1b;}}
.mic{{background:#0369a1;}}
.go{{background:#e11d48;}}
input{{width:100%;box-sizing:border-box;padding:11px;border-radius:10px;border:1px solid #3f3f5a;background:#12121a;color:#fff;font-size:.98rem;margin-bottom:8px;}}
#rep{{white-space:pre-wrap;font-size:.9rem;color:#a7f3d0;min-height:44px;max-height:220px;overflow-y:auto;}}
</style></head><body>
<h1>🌹 Tiffany AI-OS — Télécommande Complète</h1>
<div class="card stats"><span>🌡️ CPU : <b id="temp">--</b></span><span>🧠 RAM : <b id="ram">--</b></span></div>

<div class="card">
  <input id="pin" type="password" inputmode="numeric" placeholder="Code PIN (4+ chiffres)">
  <input id="msg" type="text" placeholder="Parle ou écris à Tiffany (ex: analyse, météo, résume...)">
  <div class="grid">
    <button class="mic" onclick="dicter()">🎤 Dicter (Micro)</button>
    <button class="go" onclick="send(document.getElementById('msg').value)">🚀 Envoyer</button>
  </div>
</div>

<div class="card"><div id="rep">Prêt. Tous tes modules Tiffany sont connectés.</div></div>

<div class="card">
  <h2>⚡ Contrôles Rapides Système</h2>
  <div class="grid3">
    <button onclick="send('analyse')">📊 Analyse</button>
    <button onclick="send('froid')">❄️ Froid</button>
    <button onclick="send('boost')">🚀 Boost</button>
    <button onclick="send('purge ram')">🧹 Purge RAM</button>
    <button onclick="send('son a 50')">🔉 Son 50%</button>
    <button onclick="send('son a 100')">🔊 Son 100%</button>
    <button onclick="send('mute')">🔇 Muet</button>
    <button onclick="send('reparle')">🗣️ Reparler</button>
    <button class="stop" onclick="send('stop ia')">🛑 Stop IA</button>
  </div>
</div>

<div class="card">
  <h2>🧩 Tous tes Modules & Plugins ({len(lister_outils())})</h2>
  <div class="grid">{outils_html}</div>
</div>

<div class="card">
  <h2>🔐 Sécurité & Code PIN</h2>
  <div style="display:flex;gap:8px;">
    <input id="newpin" type="password" inputmode="numeric" placeholder="Nouveau PIN (4+ chiffres)" style="margin:0;">
    <button onclick="changerPin()" style="white-space:nowrap;">Valider PIN</button>
  </div>
</div>

<script>
const pEl=document.getElementById('pin');
pEl.value=localStorage.getItem('tiff_pin')||'';
pEl.addEventListener('change',()=>localStorage.setItem('tiff_pin',pEl.value));

async function maj(){{
  try{{const r=await fetch('/stats');const d=await r.json();document.getElementById('temp').textContent=d.temp;document.getElementById('ram').textContent=d.ram;}}catch(e){{}}
}}

async function send(txt){{
  if(!txt)return;
  localStorage.setItem('tiff_pin',pEl.value);
  const rep=document.getElementById('rep');
  rep.textContent='⏳ Exécution de : '+txt+' ...';
  try{{
    const r=await fetch('/cmd',{{method:'POST',headers:{{'Content-Type':'application/x-www-form-urlencoded'}},body:'pin='+encodeURIComponent(pEl.value)+'&q='+encodeURIComponent(txt)}});
    rep.textContent=await r.text();
  }}catch(e){{rep.textContent='❌ Erreur réseau avec le PC.';}}
  document.getElementById('msg').value='';
  maj();
}}

function changerPin(){{
  const n=document.getElementById('newpin').value.trim();
  if(!n)return;
  send('SETPIN:'+n);
  pEl.value=n;
  localStorage.setItem('tiff_pin',n);
  document.getElementById('newpin').value='';
}}

function dicter(){{
  const SR=window.SpeechRecognition||window.webkitSpeechRecognition;
  if(!SR){{alert('Utilise le bouton micro de ton clavier Android dans la case texte !');return;}}
  const rec=new SR();
  rec.lang='fr-FR';
  document.getElementById('rep').textContent='🎤 Parle maintenant...';
  rec.onresult=(e)=>{{const t=e.results[0][0].transcript;document.getElementById('msg').value=t;send(t);}};
  rec.onerror=()=>{{document.getElementById('rep').textContent='🎤 Utilise le micro de ton clavier Android.';}};
  rec.start();
}}

maj();setInterval(maj,5000);
</script></body></html>"""

class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_GET(self):
        if self.path == "/stats":
            self.send_response(200); self.send_header("Content-Type","application/json"); self.end_headers()
            self.wfile.write(json.dumps(get_stats()).encode())
        else:
            self.send_response(200); self.send_header("Content-Type","text/html; charset=utf-8"); self.end_headers()
            self.wfile.write(build_html().encode("utf-8"))
    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        data = parse_qs(self.rfile.read(length).decode("utf-8"))
        if data.get("pin", [""])[0] != get_pin():
            self.send_response(403); self.end_headers()
            self.wfile.write("❌ Code PIN incorrect.".encode("utf-8"))
            return
        q_val = data.get("q", [""])[0]
        if q_val.startswith("SETPIN:"):
            npin = q_val.split(":", 1)[1].strip()
            if len(npin) >= 4 and npin.isdigit():
                open(PIN_FILE, "w").write(npin)
                res = f"✅ Nouveau code PIN enregistré : {npin}"
            else:
                res = "❌ Le PIN doit contenir au moins 4 chiffres."
        else:
            res = run_cmd(q_val)
        self.send_response(200); self.send_header("Content-Type","text/plain; charset=utf-8"); self.end_headers()
        self.wfile.write(res.encode("utf-8"))

if __name__ == "__main__":
    IP = subprocess.check_output(["hostname", "-I"]).decode().split()[0]
    URL = f"http://{IP}:8486"
    print("\n=======================================================")
    print(" 📱 COMPAGNON MOBILE COMPLET TIFFANY PRÊT")
    print(f" 🔗 Adresse téléphone : {URL}")
    print(f" 🔐 Code PIN actuel   : {get_pin()}")
    print(f" 🧩 Modules détectés  : {len(lister_outils())} boutons chargés")
    print("=======================================================\n")
    HTTPServer.allow_reuse_address = True; HTTPServer(("0.0.0.0", 8486), Handler).serve_forever()
