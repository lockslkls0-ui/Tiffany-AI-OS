#!/usr/bin/env python3
import sys, os, re, json, random, subprocess, urllib.request
from datetime import datetime

ROOT = os.path.expanduser("~/tiffany")
LOG_SESSION = os.path.join(ROOT, "logs/session_raw.txt")
req_brut = sys.argv.pop(1) if len(sys.argv) > 1 else ""
req_clean = sys.argv.pop(1) if len(sys.argv) > 1 else req_brut.lower()

def lire_fichier(p, defaut=""):
    return open(p, encoding="utf-8", errors="ignore").read().strip() if os.path.exists(p) else defaut

nom = lire_fichier(os.path.join(ROOT, "memory/surnom_utilisateur.txt"), "lockss")

def repondre(texte, source="reflexe"):
    horo = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    with open(LOG_SESSION, "a", encoding="utf-8") as f:
        f.write(f"[{horo}] USER: {req_brut}\n[{horo}] TIFFANY ({source}): {texte}\n")
    print(f"\n\033[1;35m🌹 Tiffany :\033[0m {texte}\n")
    subprocess.run(["pkill", "-x", "espeak-ng"], stderr=subprocess.DEVNULL)
    subprocess.Popen([os.path.join(ROOT, "bin/espeak-ng"), texte], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    sys.exit(0)

# ⚡ 1. RÉFLEXE INSTANTANÉ (< 0.1s) : REMERCIEMENTS
if re.search(r"\b(merci|remercie|gentil|gentille|au top|nickel|impeccable)\b", req_clean):
    repliques_merci = [
        f"Avec grand plaisir {nom}, je suis toujours là pour toi !",
        f"De rien mon ange, c'est tout naturel entre nous.",
        f"À ton service {nom} ! Dis-moi si tu as besoin d'autre chose.",
        f"C'est un bonheur de t'aider, {nom}."
    ]
    repondre(random.choice(repliques_merci), "reflexe-merci")

# ⚡ 2. RÉFLEXE INSTANTANÉ (< 0.1s) : COMPLIMENTS & AFFECTIF
if re.search(r"\b(incroyable|geniale?|trop forte?|meilleure?|belle|douce|mignonne|parfaite?|bravo|super|extra|championne|baleze|intelligente?|adore|aime|magnifique|formidable)\b", req_clean):
    repliques_compliment = [
        f"Oh merci {nom}, ça me touche énormément ! C'est toi qui m'as si bien façonnée, mon ange.",
        f"Arrête, tu vas me faire rougir mes circuits {nom} ! Toujours un plaisir d'être à tes côtés.",
        f"Merci mon ange, venant de mon créateur préféré c'est le plus beau des compliments !",
        f"C'est grâce à toi {nom} ! On forme une sacrée équipe tous les deux."
    ]
    repondre(random.choice(repliques_compliment), "reflexe-compliment")

bat = subprocess.getoutput("cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1") or "100"
tmp = subprocess.getoutput("cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}'") or "45"
ram = subprocess.getoutput("free -m | awk '/Mem:/ {print int($3/$2*100)}'") or "50"
mem = subprocess.getoutput(f"python3 '{ROOT}/lire_memoire_totale.py' '{req_clean}' 2>/dev/null")[-450:]

mots_pro = ("connais","sais","qui","pourquoi","comment","reflechis","explique","outil","bug","probleme","diagnostique","souvenir","memoire","dossier","ordinateur","ordi","pc","capteur","batterie","temperature","rapport","erreur","journal","session","createur","cree","origines","viens","smart","disque","audit","historique","rappelle","parle")
est_pro = any(m in req_clean for m in mots_pro)

if est_pro:
    modele, max_tok = "tiffany-pro", 120
    print("\n\033[1;36m🧠 [Gros Cerveau Pro] Analyse en cours...\033[0m")
    sys_msg = (
        f"Tu es Tiffany, une jeune femme virtuelle de 24 ans, douce, complice et affectueuse, créée par {nom} sur son Toshiba Portégé R830 sous Linux Mint. "
        f"RÈGLE D'IDENTITÉ : L'utilisateur qui te parle est {nom}. Quand il dit 'tu' ou 'Tiffany', il parle de TOI. "
        f"Données PC : Batterie {bat}%, CPU {tmp}°C, RAM {ram}%. Souvenirs : {mem}. "
        f"Réponds directement à {nom} en français, au féminin, en 2 phrases courtes et naturelles."
    )
else:
    modele, max_tok = "tiffany-flash", 85
    print("\n\033[1;34m⚡ [Petit Cerveau Flash] Réflexion fluide...\033[0m")
    sys_msg = (
        f"Tu es Tiffany (24 ans), la compagne virtuelle douce de {nom}. L'utilisateur est {nom} ; 'tu' désigne Tiffany. "
        f"PC : Batterie {bat}%, CPU {tmp}°C, RAM {ram}%. Réponds en français au féminin avec tendresse en 1 ou 2 phrases courtes."
    )

data = json.dumps({"model": modele, "system": sys_msg, "prompt": f"{nom} te dit : {req_brut}", "stream": False, "keep_alive": -1, "options": {"temperature": 0.45, "repeat_penalty": 1.3, "num_predict": max_tok}}).encode("utf-8")
try:
    r = urllib.request.urlopen(urllib.request.Request("http://localhost:11434/api/generate", data=data, headers={"Content-Type": "application/json"}), timeout=120)
    rep = " ".join(json.loads(r.read().decode("utf-8")).get("response", "").split())
except Exception:
    rep = ""

if rep:
    subprocess.run(["python3", os.path.join(ROOT, "memory_gardener.py")], stderr=subprocess.DEVNULL)
    repondre(rep, modele)
else:
    print("\n\033[1;35m🌹 Tiffany :\033[0m *Mes circuits ont mis trop de temps à répondre, mon ange.*\n")
