#!/usr/bin/env python3
import os, re, glob, time, subprocess, urllib.request, urllib.parse
import moteur_mobile as m

VERT = "\033[92m"
JAUNE = "\033[93m"
ROUGE = "\033[91m"
CYAN = "\033[96m"
GRAS = "\033[1m"
RESET = "\033[0m"

ROOT = os.path.expanduser("~/tiffany")
BIN_MOB = os.path.expanduser("~/tiffany/mobile/bin/zenity")

print(f"\n{CYAN}{GRAS}╔════════════════════════════════════════════════════════════════════════════╗")
print(f"║  🧪 BANC D'ESSAI INTÉGRAL SANS COMPLAISANCE — COMPAGNON MOBILE TIFFANY     ║")
print(f"╚════════════════════════════════════════════════════════════════════════════╝{RESET}\n")

erreurs = []
avertissements = []
ok_count = 0

def ok(cat, msg, detail=""):
    global ok_count
    ok_count += 1
    print(f"  {VERT}✔ [VERT ]{RESET} {cat:<16} │ {msg:<42} {CYAN}{detail}{RESET}")

def warn(cat, msg, chemin, fix):
    avertissements.append((cat, msg, chemin, fix))
    print(f"  {JAUNE}⚠ [JAUNE]{RESET} {cat:<16} │ {msg:<42} {JAUNE}(Voir bas){RESET}")

def err(cat, msg, chemin, fix):
    erreurs.append((cat, msg, chemin, fix))
    print(f"  {ROUGE}✘ [ROUGE]{RESET} {cat:<16} │ {msg:<42} {ROUGE}(Voir bas){RESET}")

# 1. INFRASTRUCTURE & SECURITE
print(f"{GRAS}▶ [1/3] INFRASTRUCTURE, SÉCURITÉ PIN & PONT INTERACTIF ZENITY{RESET}")
for f in ("moteur_mobile.py", "serveur_mobile.py", "interface.html", "bin/zenity"):
    fp = os.path.join(ROOT, "mobile", f)
    if os.path.exists(fp): ok("Fichier", f, "Présent")
    else: err("Fichier", f"Manquant : {f}", fp, f"Recréer {fp}")

if os.access(BIN_MOB, os.X_OK): ok("Pont Zenity", "Relais exécutable", BIN_MOB)
else: err("Pont Zenity", "Relais non exécutable", BIN_MOB, f"chmod +x {BIN_MOB}")

pin = m.init_pin()
if m.check_pin(pin) and not m.check_pin("0000"): ok("Sécurité PIN", "Vérification SHA-256 active", f"PIN: {pin}")
else: err("Sécurité PIN", "Échec validation SHA-256", "~/.config/tiffany/mobile_pin.hash", "Supprimer mobile_pin.hash et relancer")

# Verifier si serveur tourne sur 8486
try:
    urllib.request.urlopen("http://127.0.0", timeout=2)
    ok("Serveur HTTP", "Port 8486 en ligne", "http://127.0.0.1:8486")
except Exception:
    err("Serveur HTTP", "Serveur arrêté (port 8486 fermé)", "~/tiffany/mobile/serveur_mobile.py", "python3 ~/tiffany/mobile/serveur_mobile.py &")

# 2. AUDIT STATIQUE DES SCRIPTS (DETECTION /usr/bin/zenity EN DUR & LANCEMENTS DETACHES)
print(f"\n{GRAS}▶ [2/3] ANALYSE DES PLUGINS POUR COMPATIBILITÉ MOBILE{RESET}")
scripts = sorted(glob.glob(f"{ROOT}/plugins/*.sh") + glob.glob(f"{ROOT}/actions_terminal/*.sh"))
for sp in scripts:
    if sp.endswith(".off"): continue
    txt = open(sp, encoding="utf-8", errors="ignore").read()
    bname = os.path.basename(sp)
    if "/usr/bin/zenity" in txt:
        err("Chemin Zenity", f"{bname} force /usr/bin/zenity", sp, f"sed -i 's|/usr/bin/zenity|zenity|g' {sp}")
    if re.search(r'zenity\s+.*&\s*$', txt, re.M):
        warn("Zenity détaché", f"{bname} lance zenity en arrière-plan (&)", sp, f"Retirer le '&' final sur zenity dans {sp}")

# 3. TEST RÉEL DE CHAQUE BOUTON MOBILE
print(f"\n{GRAS}▶ [3/3] SIMULATION RÉELLE DE CLIC SUR LES BOUTONS MOBILES{RESET}")
outils = m.lister_outils()
for label, cmd in outils:
    # Trouver le fichier source correspondant
    cands = [s for s in scripts if not s.endswith(".off") and cmd.replace(" ", "_") in os.path.basename(s)]
    src = cands.pop(0) if cands else f"{ROOT}/interpreteur_universel.sh"
    try:
        # Test avec timeout court de 3s (si ca bloque sur un prompt zenity, c'est que le pont interactif s'est bien declenche !)
        env = os.environ.copy()
        env["TIFFANY_MOBILE"] = "1"
        env["PATH"] = f"{ROOT}/mobile/bin:{env.get('PATH', '')}"
        p = subprocess.Popen(["python3", "-c", f"import sys; sys.path.insert(0, '{ROOT}/mobile'); import moteur_mobile as m; print(m.executer('{cmd}'))"], env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        try:
            out, _ = p.communicate(timeout=2.5)
            res = m.clean(out.decode("utf-8", errors="ignore"))
            if "inconnu" in res.lower() or "introuvable" in res.lower() or not res:
                err("Routage Bouton", f"'{label}' -> Aucune action / Routage raté", src, f"Relier '{cmd}' directement à {src} dans moteur_mobile.py")
            else:
                ok("Bouton Direct", f"'{label}'", res[:36].replace("\n", " "))
        except subprocess.TimeoutExpired:
            p.kill()
            if os.path.exists("/tmp/tiffany_mob_prompt.json"):
                ok("Bouton Interactif", f"'{label}' -> Pop-up mobile déclenché", "OK sur téléphone")
                try: os.remove("/tmp/tiffany_mob_prompt.json")
                except Exception: pass
            else:
                warn("Bouton Bloquant", f"'{label}' attend une saisie sans pont Zenity", src, f"Vérifier read/xdotool/zenity dans {src}")
    except Exception as e:
        err("Crash Bouton", f"'{label}' -> {e}", src, f"Inspecter {src}")

total = ok_count + len(avertissements) + len(erreurs)
print(f"\n{CYAN}{GRAS}╔════════════════════════════════════════════════════════════════════════════╗")
print(f"║  📊 BILAN :  {VERT}✔ VERT : {ok_count:<3}{CYAN} │  {JAUNE}⚠ JAUNE : {len(avertissements):<3}{CYAN} │  {ROUGE}✘ ROUGE : {len(erreurs):<3}{CYAN} │ TOTAL : {total:<3} ║")
print(f"╚════════════════════════════════════════════════════════════════════════════╝{RESET}\n")

if erreurs or avertissements:
    print(f"{GRAS}🛠️  LISTE EXACTE DES ERREURS, CHEMINS ET COMMANDES DE RÉPARATION :{RESET}\n")
    for idx, (cat, msg, ch, fx) in enumerate(erreurs, 1):
        print(f"  {ROUGE}{idx}. [ROUGE - {cat}] {msg}{RESET}")
        print(f"     ↳ Chemin     : {CYAN}{ch}{RESET}")
        print(f"     ↳ Réparation : {VERT}{fx}{RESET}\n")
    for idx, (cat, msg, ch, fx) in enumerate(avertissements, len(erreurs)+1):
        print(f"  {JAUNE}{idx}. [JAUNE - {cat}] {msg}{RESET}")
        print(f"     ↳ Chemin     : {CYAN}{ch}{RESET}")
        print(f"     ↳ Réparation : {VERT}{fx}{RESET}\n")
