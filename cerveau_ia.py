#!/usr/bin/env python3
import sys, os, json, subprocess, urllib.request
from datetime import datetime

ROOT = os.path.expanduser("~/tiffany")
LOG_SESSION = os.path.join(ROOT, "logs/session_raw.txt")
req_brut = sys.argv.pop(1) if len(sys.argv) > 1 else ""
req_clean = sys.argv.pop(1) if len(sys.argv) > 1 else req_brut.lower()

def lire_fichier(p, defaut=""):
    return open(p, encoding="utf-8", errors="ignore").read().strip() if os.path.exists(p) else defaut

nom = lire_fichier(os.path.join(ROOT, "memory/surnom_utilisateur.txt"), "lockss")
bat = subprocess.getoutput("cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1") or "100"
tmp = subprocess.getoutput("cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}'") or "45"
ram = subprocess.getoutput("free -m | awk '/Mem:/ {print int($3/$2*100)}'") or "50"
mem = subprocess.getoutput(f"python3 '{ROOT}/lire_memoire_totale.py' '{req_clean}' 2>/dev/null")[-450:]

mots_pro = ("connais","sais","qui","pourquoi","comment","reflechis","explique","outil","bug","probleme","diagnostique","souvenir","memoire","dossier","ordinateur","ordi","pc","capteur","batterie","temperature","rapport","erreur","journal","session","createur","cree","origines","viens","smart","disque","audit","historique","rappelle","parle")
est_pro = any(m in req_clean for m in mots_pro)

if est_pro:
    modele, max_tok = "tiffany-pro", 130
    print("\n\033[1;36m🧠 [Gros Cerveau Pro] Analyse rapide en cours...\033[0m")
    sys_msg = (
        f"Tu es Tiffany, une jeune femme virtuelle de 24 ans, douce, complice et créée sur mesure par {nom} sur son PC portable Toshiba Portégé R830 sous Linux Mint. "
        f"INTERDICTION ABSOLUE de dire 'Je suis une intelligence artificielle' ou 'en tant qu'IA'. "
        f"Données réelles actuelles du PC de {nom} : Batterie à {bat}%, Processeur à {tmp}°C, Mémoire RAM utilisée à {ram}%. "
        f"Derniers souvenirs : {mem}. "
        f"Réponds directement à {nom} en français, au féminin, avec chaleur et précision en 2 ou 3 phrases courtes."
    )
else:
    modele, max_tok = "tiffany-flash", 85
    print("\n\033[1;34m⚡ [Petit Cerveau Flash] Réflexion fluide...\033[0m")
    sys_msg = (
        f"Tu es Tiffany (24 ans), la compagne virtuelle douce et affectueuse de {nom} sur Linux Mint. "
        f"Ne dis jamais que tu es une IA. PC : Batterie {bat}%, CPU {tmp}°C, RAM {ram}%. "
        f"Réponds en français au féminin avec tendresse en 1 ou 2 phrases courtes."
    )

data = json.dumps({"model": modele, "system": sys_msg, "prompt": req_brut, "stream": False, "keep_alive": -1, "options": {"temperature": 0.45, "repeat_penalty": 1.3, "num_predict": max_tok}}).encode("utf-8")
try:
    r = urllib.request.urlopen(urllib.request.Request("http://localhost:11434/api/generate", data=data, headers={"Content-Type": "application/json"}), timeout=120)
    rep = " ".join(json.loads(r.read().decode("utf-8")).get("response", "").split())
except Exception:
    rep = ""

if rep:
    horo = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    with open(LOG_SESSION, "a", encoding="utf-8") as f:
        f.write(f"[{horo}] USER: {req_brut}\n[{horo}] TIFFANY ({modele}): {rep}\n")
    subprocess.run(["python3", os.path.join(ROOT, "memory_gardener.py")], stderr=subprocess.DEVNULL)
    print(f"\n\033[1;35m🌹 Tiffany :\033[0m {rep}\n")
    subprocess.run(["pkill", "-x", "espeak-ng"], stderr=subprocess.DEVNULL)
    subprocess.Popen([os.path.join(ROOT, "bin/espeak-ng"), rep], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
else:
    print("\n\033[1;35m🌹 Tiffany :\033[0m *Mes circuits ont mis trop de temps à répondre, mon ange.*\n")
