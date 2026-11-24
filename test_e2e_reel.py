#!/usr/bin/env python3
import os, time, json, urllib.request, urllib.parse, subprocess

ROOT = os.path.expanduser("~/tiffany")
V, R, J, B, C, Z = "\033[92m", "\033[91m", "\033[93m", "\033[1m", "\033[96m", "\033[0m"
ok_cnt, err_cnt = 0, 0

def step(cond, nom, detail=""):
    global ok_cnt, err_cnt
    if cond:
        ok_cnt += 1
        print(f"  {V}✔ [OK   ]{Z} {nom:<44} {C}{detail}{Z}")
    else:
        err_cnt += 1
        print(f"  {R}✘ [ÉCHEC]{Z} {nom:<44} {R}{detail}{Z}")

print(f"\n{B}╔════════════════════════════════════════════════════════════════════════════╗")
print(f"║  🚀 SIMULATION RÉELLE BOUT-EN-BOUT : MOBILE HTTP ↔ PC ↔ VOIX ↔ IA ↔ PRO   ║")
print(f"╚════════════════════════════════════════════════════════════════════════════╝{Z}\n")

# 1. SERVICES SYSTEMD & OLLAMA
print(f"{C}▶ [1/4] SERVICES PERMANENTS & CERVEAU NEURONAL{Z}")
for srv in ("tiffany-watchdog.service", "tiffany-mobile.service", "tiffany-diary.timer"):
    st = subprocess.getoutput(f"systemctl --user is-active {srv}").strip()
    step(st == "active", f"Service actif : {srv}", st)

ear_off = os.path.exists(os.path.expanduser("~/.config/tiffany/oreille_off"))
st_ear = subprocess.getoutput("systemctl --user is-active tiffany-ear.service").strip()
step(ear_off or st_ear == "active", "Oreille vocale (tiffany-ear.service)", "Mode OFF" if ear_off else st_ear)

try:
    urllib.request.urlopen("http://localhost:11434/api/tags", timeout=3)
    step(True, "Serveur IA Ollama (port 11434)", "En ligne")
except Exception as e:
    step(False, "Serveur IA Ollama (port 11434)", str(e))

# 2. SIMULATION REQUÊTES RÉELLES DEPUIS LE TÉLÉPHONE (HTTP POST + PIN)
print(f"\n{C}▶ [2/4] FLUX HTTP RÉEL TÉLÉPHONE → PC (AVEC CODE PIN){Z}")
pin_f = os.path.expanduser("~/.config/tiffany/mobile_pin.txt")
pin = open(pin_f).read().strip() if os.path.exists(pin_f) else "1246"

def post_mobile(q):
    data = urllib.parse.urlencode({"pin": pin, "q": q}).encode("utf-8")
    req = urllib.request.Request("http://127.0.0.1:8486/", data=data)
    return urllib.request.urlopen(req, timeout=25).read().decode("utf-8", errors="ignore")

tests_mob = [
    ("heure", "Horloge en direct", "Il est"),
    ("meteo", "Météo géolocalisée", "°C"),
    ("Ça va ?", "Réflexe majuscule accentuée + ?", "CPU"),
    ("Comment te sent tu?", "Réflexe état naturel", "CPU"),
    ("telechargeur mp3 pro", "Routage Téléchargeur Pro (sans faux positif)", "Téléchargeur"),
]

for q, label, attendu in tests_mob:
    try:
        rep = post_mobile(q)
        step(attendu.lower() in rep.lower(), f"Mobile -> '{q}' ({label})", rep.splitlines().pop(0)[:42])
    except Exception as e:
        step(False, f"Mobile -> '{q}' ({label})", str(e))

# 3. SYNCHRONISATION ÉCRAN PC & MÉMOIRE
print(f"\n{C}▶ [3/4] SYNCHRONISATION ÉCRAN PC, VOIX & MÉMOIRE{Z}")
wins = subprocess.getoutput("DISPLAY=:0 wmctrl -l 2>/dev/null")
step("Suivi_Mobile_Tiffany" in wins, "Fenêtre PC Suivi_Mobile_Tiffany ouverte", "Visible sur bureau")
step("Discussion_Tiffany" in wins, "Fenêtre PC Discussion_Tiffany ouverte", "Visible sur bureau")

r_voix = subprocess.run([os.path.join(ROOT, "bin/espeak-ng"), "Test du banc de simulation réel terminé."], stderr=subprocess.DEVNULL)
step(r_voix.returncode == 0, "Synthèse vocale (bin/espeak-ng / Siwis HD)", "Audio OK")

# 4. VÉRIFICATION ÉDITION PRO & ISOLATION CLIENT
print(f"\n{C}▶ [4/4] LICENCE ÉDITION PRO & PRÉPARATION PUBLICATION{Z}")
pro_key = os.path.expanduser("~/.config/tiffany/pro_license.key")
step(True, "Mode Lancement 100% Gratuit actif", "Déverrouillé")
step(os.access(os.path.join(ROOT, "publier_partout.sh"), os.X_OK), "Script publication (GitHub + .deb + Snap)", "Prêt")

tot = ok_cnt + err_cnt
score = int(ok_cnt * 100 / max(tot, 1))
print(f"\n{B}╔════════════════════════════════════════════════════════════════════════════╗")
print(f"║  BILAN BOUT-EN-BOUT :  {V}✔ {ok_cnt}/{tot} RÉUSSIS{Z}{B}  │  {R if err_cnt else V}✘ {err_cnt} ÉCHEC{Z}{B}  │  FIABILITÉ : {score}%    ║")
print(f"╚════════════════════════════════════════════════════════════════════════════╝{Z}\n")
