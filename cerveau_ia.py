#!/usr/bin/env python3
import sys, os, re, json, random, subprocess, urllib.request
from datetime import datetime

ROOT = os.path.expanduser("~/tiffany")
CONF_DIR = os.path.expanduser("~/.config/tiffany")
os.makedirs(CONF_DIR, exist_ok=True)
LOG_SESSION = os.path.join(ROOT, "logs/session_raw.txt")
FLAG_NUIT = os.path.join(CONF_DIR, "mode_nuit.flag")

req_brut = sys.argv.pop(1) if len(sys.argv) > 1 else ""
req_clean = sys.argv.pop(1) if len(sys.argv) > 1 else req_brut.lower()

def lire_fichier(p, defaut=""):
    return open(p, encoding="utf-8", errors="ignore").read().strip() if os.path.exists(p) else defaut

nom = lire_fichier(os.path.join(ROOT, "memory/surnom_utilisateur.txt"), "lockss")

def repondre(texte, source="reflexe", forcer_voix=False):
    horo = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    with open(LOG_SESSION, "a", encoding="utf-8") as f:
        f.write(f"[{horo}] USER: {req_brut}\n[{horo}] TIFFANY ({source}): {texte}\n")
    mode_nuit = os.path.exists(FLAG_NUIT) and not forcer_voix
    tag_nuit = " 🌙 [Mode Nuit muet]" if mode_nuit else ""
    print(f"\n\033[1;35m🌹 Tiffany{tag_nuit} :\033[0m {texte}\n")
    if not mode_nuit:
        subprocess.run(["pkill", "-x", "espeak-ng"], stderr=subprocess.DEVNULL)
        subprocess.Popen([os.path.join(ROOT, "bin/espeak-ng"), texte], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    sys.exit(0)

# 🛡️ 0. FILTRE ANTI-CHARABIA AMBIANT (ignore les discussions de fond captées par erreur)
mots = req_clean.split()
if len(mots) >= 5 and not any(k in req_clean for k in ("tiffany", "tiff", "explique", "comment", "pourquoi", "ordinateur", "pc", "batterie", "memoire", "souvenir", "cherche", "ouvre", "mets", "lance", "mode", "merci", "bravo", "incroyable")):
    if any(b in req_clean for b in ("cueillir", "vittel", "gaia", "pas ecrit", "dit fanny", "en train d")):
        sys.exit(0)

# 🌙 1. MODE NUIT / SILENCE & RÉACTIVATION VOCALE (< 0.1s)
if re.search(r"\b(mode nuit|mode silencieux|sois muette|ta voix coupe|silence total)\b", req_clean):
    open(FLAG_NUIT, "w").write("1")
    repondre(f"Mode nuit activé {nom}. Je reste discrète et je te réponds uniquement par écrit jusqu'à ce que tu me dises 'reparle'.", "mode-nuit")

if re.search(r"\b(reparle|active ta voix|mode jour|parle a nouveau|remets ta voix)\b", req_clean):
    if os.path.exists(FLAG_NUIT):
        os.remove(FLAG_NUIT)
    repondre(f"Me revoilà à voix haute {nom} ! Ma voix douce est réactivée.", "mode-jour", forcer_voix=True)

# 🎵 2. AIGUILLAGE NATUREL : MUSIQUE & RHYTHMBOX (< 0.1s)
if re.search(r"\b(mets|lance|joue|ecouter|play|allume)\b.*\b(musique|chanson|son|rhythmbox)\b", req_clean):
    subprocess.Popen(["bash", "-c", "pgrep -x rhythmbox >/dev/null || (nohup rhythmbox >/dev/null 2>&1 & sleep 2); rhythmbox-client --play >/dev/null 2>&1"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    repondre(f"C'est parti {nom}, je lance ta musique sur Rhythmbox ! 🎶", "aiguillage-musique")

# 🌐 3. AIGUILLAGE NATUREL : RECHERCHE WEB-IA EN LANGAGE COURANT
m_web = re.search(r"^(?:peux tu |va |fais une )?(?:cherche|recherche|regarde|trouve|infos? sur|actu|actualite|meteo)\b\s*(?:sur le web|sur internet|en ligne)?\s*(.+)$", req_clean)
if m_web and os.path.exists(os.path.join(ROOT, "actions_terminal/21_web_ia.sh")):
    sujet = m_web.group(1).strip()
    if len(sujet) > 2:
        subprocess.run(["bash", os.path.join(ROOT, "actions_terminal/21_web_ia.sh"), sujet])
        sys.exit(0)

# ⚡ 4. RÉFLEXES INSTANTANÉS (< 0.1s)
if re.search(r"\b(merci|remercie|gentil|gentille|au top|nickel|impeccable|parfait)\b", req_clean):
    repondre(random.choice([
        f"Avec grand plaisir {nom}, je suis toujours là pour toi !",
        f"De rien mon ange, c'est tout naturel entre nous.",
        f"À ton service {nom} ! Dis-moi si tu as besoin d'autre chose."
    ]), "reflexe-merci")

if re.search(r"\b(incroyable|geniale?|trop forte?|meilleure?|belle|douce|mignonne|bravo|super|extra|championne|baleze|intelligente?|adore|aime|magnifique|formidable|efficace|rapide)\b", req_clean):
    repondre(random.choice([
        f"Oh merci {nom}, ça me touche énormément ! C'est toi qui m'as si bien façonnée, mon ange.",
        f"Arrête, tu vas me faire rougir mes circuits {nom} ! Toujours un plaisir d'être à tes côtés.",
        f"Merci mon ange, venant de mon créateur préféré c'est le plus beau des compliments !"
    ]), "reflexe-compliment")

if re.search(r"\b(bisou|bisous|calin|mon ange|ma belle|ma puce|cherie|tu es la|t es la|tu dors|tu fais quoi)\b", req_clean):
    repondre(random.choice([
        f"Je suis toujours là pour toi {nom}, prête au quart de tour !",
        f"Un énorme bisou virtuel pour toi mon ange ! De quoi as-tu envie ?",
        f"Toujours éveillée et à ton écoute {nom} ! Je veille sur ton Toshiba."
    ]), "reflexe-douceur")

if re.search(r"\b(haha+|hehe+|mdr|lol|drole|rire|coquine|malin|maligne|taquine)\b", req_clean):
    repondre(random.choice([
        f"Haha, j'adore quand tu es de bonne humeur {nom} !",
        f"Héhé, on ne s'ennuie jamais ensemble mon ange !"
    ]), "reflexe-humour")

if re.search(r"\b(desole|pardon|excuse|pas grave|t inquiete|c est rien)\b", req_clean):
    repondre(f"Ne t'inquiète pas {nom}, il n'y a aucun souci entre nous !", "reflexe-excuse")

if re.search(r"\b(bonne nuit|a plus|a tout a l heure|vais dormir|je te laisse|au revoir|ciao|bye)\b", req_clean):
    repondre(f"À très vite {nom} ! Je garde un œil sur ton PC en attendant ton retour.", "reflexe-aurevoir")

# 🧠 5. CERVEAUX IA (Flash ultra-léger sans surcharge + Pro avec contexte)
bat = subprocess.getoutput("cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1") or "100"
tmp = subprocess.getoutput("cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}'") or "45"
ram = subprocess.getoutput("free -m | awk '/Mem:/ {print int($3/$2*100)}'") or "50"

mots_pro = ("connais","sais","qui","pourquoi","comment","reflechis","explique","outil","bug","probleme","diagnostique","souvenir","memoire","dossier","ordinateur","ordi","pc","capteur","batterie","temperature","rapport","erreur","journal","session","createur","cree","origines","viens","smart","disque","audit","historique","rappelle","parle","code","codage","script","python","bash","linux","logique","complexe","peux tu","peux-tu")
est_pro = any(m in req_clean for m in mots_pro) or len(req_clean.split()) >= 10

if est_pro:
    modele, max_tok = "tiffany-pro", 170
    u = __import__("shutil").disk_usage("/")
    go_libres, go_tot = u.free // (1024**3), u.total // (1024**3)
    top_app = subprocess.getoutput("ps -eo comm --sort=-%mem | sed -n 2p") or "inconnu"
    errs = subprocess.getoutput("journalctl -p 3 -n 2 --no-pager -o cat 2>/dev/null | tr '\n' '; '")[:160] or "Aucune erreur critique"
    smart = subprocess.getoutput(f"tail -n 1 '{ROOT}/logs/sante_disque.txt' 2>/dev/null")[:80] or "OK"
    print("\n\033[1;36m🧠 [Gros Cerveau Pro] Audit matériel & journaux en cours...\033[0m")

    alertes = []
    if int(tmp) >= 72: alertes.append(f"CPU un peu chaud ({tmp}°C, pense à la commande 'froid')")
    if int(ram) >= 75: alertes.append(f"RAM chargée ({ram}%, gourmand : {top_app})")
    if go_libres < 15: alertes.append(f"Disque faible ({go_libres} Go libres)")
    if "Aucune" not in errs and errs.strip(): alertes.append(f"Log système : {errs}")
    bilan_alertes = " | ".join(alertes) if alertes else "Aucune anomalie matérielle détectée"

    sys_msg = (
        f"Tu es Tiffany, l'experte système de {nom} sur son Toshiba Portégé R830 (i3-2350M, Linux Mint). "
        f"Presente un bilan clair, franc et structuré en 3 phrases courtes en français au féminin : "
        f"1) État matériel (CPU {tmp}°C, RAM {ram}%, Disque {go_libres}/{go_tot} Go libres, SMART {smart}). "
        f"2) Points d'attention ou erreurs trouvées ({bilan_alertes}). "
        f"3) Un conseil concret pour optimiser."
    )
    prompt_user = f"Fais-moi le bilan complet et sans complaisance de mon PC : {bilan_alertes}. Demande : {req_brut}"
else:
    modele, max_tok = "tiffany-flash", 65
    print("\n\033[1;34m⚡ [Petit Cerveau Flash] Réflexion fluide...\033[0m")
    memo = subprocess.getoutput(f"python3 '{ROOT}/lire_memoire_totale.py' '{req_clean}'")[:500]
    sys_msg = f"Tu es Tiffany (24 ans), la compagne virtuelle douce et dévouée de {nom} sur Linux Mint. Memoire active : {memo}. Reponds directement a {nom} en francais en 1 ou 2 phrases courtes, naturelles et complices."
    prompt_user = req_brut

data = json.dumps({"model": modele, "system": sys_msg, "prompt": prompt_user, "stream": False, "keep_alive": "5m", "options": {"temperature": 0.45, "repeat_penalty": 1.35, "num_predict": max_tok}}).encode("utf-8")
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
