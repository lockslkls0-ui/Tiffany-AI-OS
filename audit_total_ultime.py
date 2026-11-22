#!/usr/bin/env python3
import os, glob, subprocess, py_compile, time

ROOT = os.path.expanduser("~/tiffany")
V, J, R, N = "\033[1;32m", "\033[1;33m", "\033[1;31m", "\033[0m"
C, B = "\033[1;36m", "\033[1m"
verts = jaunes = rouges = 0

def ok(cat, msg, chemin=""):
    global verts; verts += 1
    p = f" ({chemin})" if chemin else ""
    print(f"  {V}✔ [VERT ]{N} {cat:<16} │ {msg}{p}")

def warn(cat, msg, chemin, fix):
    global jaunes; jaunes += 1
    print(f"  {J}⚠ [JAUNE]{N} {cat:<16} │ {msg}\n             {C}↳ Chemin :{N} {chemin}\n             {C}↳ Action :{N} {fix}")

def err(cat, msg, chemin, fix):
    global rouges; rouges += 1
    print(f"  {R}✘ [ROUGE]{N} {cat:<16} │ {msg}\n             {C}↳ Chemin :{N} {chemin}\n             {C}↳ Fix    :{N} {fix}")

print(f"\n{B}╔══════════════════════════════════════════════════════════════════════════════╗{N}")
print(f"{B}║   🔬 GRAND BANC D'ESSAI ULTIME — AUDIT 100% CODE, ALIAS, AUDIO & CERVEAUX    ║{N}")
print(f"{B}╚══════════════════════════════════════════════════════════════════════════════╝{N}")

print(f"\n{C}▶ [1/5] ARBORESCENCE, FICHIERS VIDES & PERMISSIONS (+x){N}")
for d in ["actions_terminal", "plugins", "ear_modules", "agents", "memory", "logs", "voice", "bin"]:
    dp = os.path.join(ROOT, d)
    if os.path.isdir(dp): ok("Dossier", f"{d}/ ({len(os.listdir(dp))} fichiers)", dp)
    else: err("Dossier", f"Manquant : {d}/", dp, f"mkdir -p {dp}")

for f in glob.glob(os.path.join(ROOT, "**/*"), recursive=True):
    if os.path.isfile(f) and "__pycache__" not in f and ".git" not in f:
        if os.path.getsize(f) == 0 and not f.endswith((".txt", ".log", ".flag", ".conf", ".tmp")) and os.path.basename(f) != "ollama":
            err("Fichier vide", f"0 octet détecté : {os.path.basename(f)}", f, f"git -C {ROOT} checkout HEAD -- {os.path.relpath(f, ROOT)}")
        if f.endswith(".sh") and not os.access(f, os.X_OK):
            warn("Permission", f"Non exécutable (+x manquant) : {os.path.basename(f)}", f, f"chmod +x {f}")

print(f"\n{C}▶ [2/5] COMPILATION INTÉGRALE BASH & PYTHON{N}")
sh_files = [f for f in glob.glob(os.path.join(ROOT, "**/*.sh"), recursive=True) if ".git" not in f]
py_files = [f for f in glob.glob(os.path.join(ROOT, "**/*.py"), recursive=True) if ".git" not in f]
sh_err = 0
for s in sh_files:
    p = subprocess.run(["bash", "-n", s], capture_output=True, text=True)
    if p.returncode != 0:
        sh_err += 1
        err("Syntaxe Bash", p.stderr.strip().splitlines()[-1], s, f"bash -n {s}")
if sh_err == 0: ok("Syntaxe Bash", f"{len(sh_files)} scripts Bash compilés avec 0 erreur")

py_err = 0
for py in py_files:
    try: py_compile.compile(py, doraise=True)
    except Exception as e:
        py_err += 1
        err("Syntaxe Python", str(e).splitlines()[0], py, f"python3 -m py_compile {py}")
if py_err == 0: ok("Syntaxe Python", f"{len(py_files)} scripts Python compilés avec 0 erreur")

print(f"\n{C}▶ [3/5] CHAÎNE AUDIO, VOIX SIWIS HD, ANTI-ÉCHO & SERVICES SYSTEMD{N}")
checks_sys = [
    ("Modèle Vosk FR", os.path.isdir(os.path.join(ROOT, "voice/vosk-fr/vosk-model-small-fr-0.22")), os.path.join(ROOT, "voice/vosk-fr/vosk-model-small-fr-0.22"), "Vérifier dossier modèle Vosk"),
    ("Voix Siwis HD", os.path.isfile(os.path.join(ROOT, "voice/fr_FR-siwis-low.onnx")), os.path.join(ROOT, "voice/fr_FR-siwis-low.onnx"), "Télécharger fr_FR-siwis-low.onnx"),
    ("Verrou anti-écho", "tiffany_parle.lock" in open(os.path.join(ROOT, "bin/espeak-ng")).read(), os.path.join(ROOT, "bin/espeak-ng"), "Ajouter touch /tmp/tiffany_parle.lock"),
    ("Serveur Ollama", subprocess.run(["curl", "-s", "http://localhost:11434/api/tags"], capture_output=True).returncode == 0, "port 11434", "systemctl start ollama"),
]
for nom_c, cond, ch, fx in checks_sys:
    if cond: ok("Système", nom_c, ch)
    else: err("Système", f"Échec : {nom_c}", ch, fx)

for srv in ["tiffany-ear.service", "tiffany-watchdog.service", "tiffany-diary.timer"]:
    st = subprocess.getoutput(f"systemctl --user is-active {srv}").strip()
    if st == "active": ok("Service", f"{srv} actif")
    else: warn("Service", f"{srv} état : {st}", f"~/.config/systemd/user/{srv}", f"systemctl --user restart {srv}")

print(f"\n{C}▶ [4/5] STRESS-TEST MASSIF : TOUTES LES VARIANTES D'ALIAS & PHONÉTIQUE{N}")
corr_sh = os.path.join(ROOT, "correcteur_phonetique.sh")
var_file = os.path.join(ROOT, "variantes_utilisateur.txt")
tests_var = []
if os.path.exists(var_file):
    for line in open(var_file, encoding="utf-8", errors="ignore"):
        line = line.strip()
        if not line or line.startswith("#"): continue
        for sep in ("->", "=", ":"):
            if sep in line:
                a, b = [x.strip() for x in line.split(sep, 1)]
                if sep == ":": a, b = b, a
                for v in a.split("|"):
                    if v.strip() and b: tests_var.append((v.strip(), b))
                break

for phrase_in, attendu in tests_var:
    out = subprocess.getoutput(f"bash '{corr_sh}' \"{phrase_in}\"").strip()
    if attendu in out or out == attendu:
        ok("Variante Alias", f"'{phrase_in}' ➔ '{out}'")
    else:
        warn("Variante Alias", f"'{phrase_in}' a donné '{out}' (attendu: '{attendu}')", var_file, f"Ajouter '{phrase_in}={attendu}' dans variantes_utilisateur.txt")

# Test des ordres vocaux critiques et rejet du bruit
ordres = ["ouvre youtube", "tu google", "mets de la musique", "heure", "cpu", "ram", "froid", "boost", "souvenirs", "audit", "webia", "mode nuit", "reparle"]
for o in ordres:
    out = subprocess.getoutput(f"bash '{corr_sh}' \"{o}\"").strip()
    if out: ok("Ordre Vocal", f"'{o}' ➔ '{out}'")
    else: err("Ordre Vocal", f"'{o}' renvoyé vide", corr_sh, "Vérifier correcteur_phonetique.sh")

print(f"\n{C}▶ [5/5] CERVEAUX IA (RÉFLEXES < 0.1s & AIGUILLAGE FLASH / PRO){N}")
cerveau = os.path.join(ROOT, "cerveau_ia.py")
txt_c = open(cerveau, encoding="utf-8").read() if os.path.exists(cerveau) else ""
for feat, pat in [("Réflexe Merci", "reflexe-merci"), ("Réflexe Compliment", "reflexe-compliment"), ("Mode Nuit", "mode-nuit"), ("Aiguillage Musique", "aiguillage-musique"), ("Aiguillage Web-IA", "21_web_ia.sh"), ("Sonde Matérielle Pro", "journalctl")]:
    if pat in txt_c: ok("Cerveau IA", f"Module actif : {feat}", cerveau)
    else: err("Cerveau IA", f"Module absent : {feat}", cerveau, "Mettre à jour ~/tiffany/cerveau_ia.py")

print(f"\n{B}╔══════════════════════════════════════════════════════════════════════════════╗{N}")
print(f"{B}║  BILAN GLOBAL :  {V}✔ VERT : {verts:<4}{N}  │  {J}⚠ JAUNE : {jaunes:<4}{N}  │  {R}✘ ROUGE : {rouges:<4}{N}             ║{N}")
print(f"{B}╚══════════════════════════════════════════════════════════════════════════════╝{N}\n")
