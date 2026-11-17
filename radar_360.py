#!/usr/bin/env python3
import os, glob, subprocess, shutil, importlib.util, urllib.request, time

ROOT = os.path.expanduser("~/tiffany")
V, R, J, B, C, G, Z = "\033[92m", "\033[91m", "\033[93m", "\033[96m", "\033[95m", "\033[90m", "\033[0m"
ok_cnt, err_cnt, fixes = 0, 0, []

def test(cond, cat, label, detail="", fix=""):
    global ok_cnt, err_cnt
    if cond:
        ok_cnt += 1
        print(f"  {V}✔ [VERT ]{Z} {label:<50} {G}{detail}{Z}")
    else:
        err_cnt += 1
        print(f"  {R}✘ [ROUGE]{Z} {label:<50} {R}{detail}{Z}")
        if fix: fixes.append((cat, label, detail, fix))

print(f"\n{B}╔════════════════════════════════════════════════════════════════════════════╗")
print(f"║     🛡️  RADAR IMPITOYABLE 360° — AUDIT RÉEL & ZÉRO COMPLAISANCE            ║")
print(f"╚════════════════════════════════════════════════════════════════════════════╝{Z}")

# 1. ARBORESCENCE & FICHIERS NON VIDES
print(f"\n{C}▶ [1/6] ARBORESCENCE & INTEGRITÉ DES FICHIERS VITAUX{Z}")
for d in ["actions_terminal", "plugins", "ear_modules", "agents", "memory", "logs", "voice", "bin", "dojo", "backup"]:
    p = os.path.join(ROOT, d)
    test(os.path.isdir(p), "Dossiers", f"Répertoire : {d}/", f"({len(os.listdir(p)) if os.path.isdir(p) else 0} éléments)", f"mkdir -p {p}")

for f_vital in ["tiffany_core.sh", "tiffany_actions.sh", "interpreteur_universel.sh", "reflexes_intelligents.sh", "tiffany_outils.sh", "tiffany_menu.sh", "dictionnaire_flash.txt", "variantes_utilisateur.txt", "actions_terminal/dictionnaire_ia.txt"]:
    fp = os.path.join(ROOT, f_vital)
    taille = os.path.getsize(fp) if os.path.exists(fp) else 0
    test(taille > 20, "Fichiers", f"Fichier vital non vide : {f_vital}", f"({taille} octets)", f"Vérifier {fp}")

# 2. SYNTAXE & ABSENCE DE DOUBLONS EN MÉMOIRE
print(f"\n{C}▶ [2/6] SYNTAXE CODE & CHASSE AUX PROCESSUS EN DOUBLE{Z}")
sh_files = [f for f in sorted(glob.glob(ROOT + "/**/*.sh", recursive=True)) if "/backup/" not in f]
py_files = [f for f in sorted(glob.glob(ROOT + "/**/*.py", recursive=True)) if "/backup/" not in f]

bad_sh = [os.path.basename(f) for f in sh_files if subprocess.run(["bash", "-n", f], capture_output=True).returncode != 0]
test(len(bad_sh) == 0, "Syntaxe", f"Compilation Bash ({len(sh_files)} scripts)", f"Erreurs: {bad_sh}" if bad_sh else "0 erreur", "Corriger bash -n")

bad_py = [os.path.basename(f) for f in py_files if subprocess.run(["python3", "-m", "py_compile", f], capture_output=True).returncode != 0]
test(len(bad_py) == 0, "Syntaxe", f"Compilation Python ({len(py_files)} scripts)", f"Erreurs: {bad_py}" if bad_py else "0 erreur", "Corriger py_compile")

ps_lines = subprocess.getoutput("ps -eo args").splitlines()
nb_ear = sum(1 for l in ps_lines if "03_moteur_ecoute.py" in l and "python" in l)
test(nb_ear <= 1, "Doublons", "Instance unique Oreille Vocale (03_moteur_ecoute)", f"Actifs: {nb_ear}", "pkill -f 03_moteur_ecoute.py && systemctl --user restart tiffany-ear.service")

nb_core = sum(1 for l in ps_lines if "tiffany_core.sh" in l and "bash" in l)
test(nb_core <= 1, "Doublons", "Instance unique Console (tiffany_core.sh)", f"Actifs: {nb_core}", "pkill -f tiffany_core.sh")

nb_menu = int(subprocess.getoutput("wmctrl -l 2>/dev/null | grep -c TIFFANY_OS") or 0)
test(nb_menu <= 1, "Doublons", "Instance unique Panneau (tiffany_menu.sh)", f"Actifs: {nb_menu}", "pkill -f tiffany_menu.sh")

# 3. VOIX SIWIS HD, PROFIL VERROUILLÉ & MICRO
print(f"\n{C}▶ [3/6] CHAÎNE VOCALE (VOIX LÉGÈRE / DOUCE SIWIS HD) & AUDIO{Z}")
wrapper = os.path.join(ROOT, "bin/espeak-ng")
w_txt = open(wrapper).read() if os.path.exists(wrapper) else ""
test(os.access(wrapper, os.X_OK) and "16000" in w_txt and "mode_voix.txt" in w_txt, "Voix", "Wrapper vocal calibré (16000 Hz + sélecteur)", "Verrouillé", "Vérifier bin/espeak-ng")
test(os.path.exists(os.path.join(ROOT, "voice/fr_FR-siwis-low.onnx")), "Voix", "Modèle Siwis HD (fr_FR-siwis-low.onnx)", "Présent", "Vérifier voice/")
mode_v = open(os.path.join(ROOT, "voice/mode_voix.txt")).read().strip() if os.path.exists(os.path.join(ROOT, "voice/mode_voix.txt")) else ""
test(mode_v in ("piper", "espeak"), "Voix", "Profil vocal actif enregistré", f"Profil: {mode_v}", "echo piper > ~/tiffany/voice/mode_voix.txt")
mute_out = subprocess.getoutput("pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null")
test("no" in mute_out.lower() or "non" in mute_out.lower(), "Audio", "Microphone physique actif (non muet)", mute_out.strip(), "pactl set-source-mute @DEFAULT_SOURCE@ 0")

# 4. SERVICES SYSTEMD, ARCHIVISTE MÉMOIRE & OLLAMA
print(f"\n{C}▶ [4/6] SERVICES SYSTEMD, ARCHIVISTE 30 MIN & CERVEAU IA{Z}")
wd_ok = subprocess.run(["systemctl", "--user", "is-active", "--quiet", "tiffany-watchdog.service"]).returncode == 0
test(wd_ok, "Services", "Sentinelle Thermique (tiffany-watchdog.service)", "Active", "systemctl --user enable --now tiffany-watchdog.service")

diary_ok = subprocess.run(["systemctl", "--user", "is-active", "--quiet", "tiffany-diary.timer"]).returncode == 0
test(diary_ok, "Services", "Archiviste Mémoire 30 min (tiffany-diary.timer)", "Actif", "systemctl --user enable --now tiffany-diary.timer")

ear_off = os.path.exists(os.path.expanduser("~/.config/tiffany/oreille_off"))
ear_ok = ear_off or (subprocess.run(["systemctl", "--user", "is-active", "--quiet", "tiffany-ear.service"]).returncode == 0)
test(ear_ok, "Services", "Service Oreille Continue (tiffany-ear.service)", "Mode OFF (pause)" if ear_off else "Active", "systemctl --user enable --now tiffany-ear.service")

j_path = os.path.join(ROOT, "memory/journal_de_bord.txt")
age_j = (time.time() - os.path.getmtime(j_path)) / 3600 if os.path.exists(j_path) else 999
test(age_j < 24, "Mémoire", "Écriture récente du journal de bord (< 24h)", f"Modifié il y a {round(age_j, 1)}h", "systemctl --user start tiffany-diary.service")

try:
    urllib.request.urlopen("http://127.0.0", timeout=2)
    api_ok = True
except Exception:
    api_ok = False
test(api_ok, "IA", "Serveur neuronal local Ollama (port 11434)", "En ligne", "sudo snap start ollama")

# 5. BOUTONS & RACCOURCIS
print(f"\n{C}▶ [5/6] INTERFACE GRAPHIQUE & RACCOURCIS BUREAU{Z}")
plugins = glob.glob(os.path.join(ROOT, "plugins/*.sh"))
actions = glob.glob(os.path.join(ROOT, "actions_terminal/*.sh"))
test(len(plugins) >= 35, "Interface", "Plugins Panneau Tiffany", f"{len(plugins)} boutons", "Vérifier plugins/")
test(len(actions) >= 25, "Outils", "Outils Terminal rapide", f"{len(actions)} outils", "Vérifier actions_terminal/")
test(os.path.exists(os.path.expanduser("~/Bureau/Panneau Tiffany.desktop")), "Bureau", "Raccourci Bureau : Panneau Tiffany", "OK", "Recréer raccourci")
test(os.path.exists(os.path.expanduser("~/Bureau/Export_Complet_IA_Tiffany.desktop")), "Bureau", "Raccourci Bureau : Export Complet IA", "OK", "Recréer raccourci")
test(os.path.exists(os.path.expanduser("~/Bureau/Radar_360_Tiffany.desktop")), "Bureau", "Raccourci Bureau : Radar 360°", "OK", "Recréer raccourci")

# 6. TEST RÉEL DE ROUTAGE VOCAL & ANTI-BRUIT
print(f"\n{C}▶ [6/6] TEST RÉEL DE ROUTAGE VOCAL & FILTRE ANTI-BRUIT{Z}")
spec = importlib.util.spec_from_file_location("f", os.path.join(ROOT, "ear_modules/02_filtre_alias.py"))
filtre = importlib.util.module_from_spec(spec); spec.loader.exec_module(filtre)

for b in ("hum", "tuk", "coque", "oui"):
    r, _ = filtre.filtrer(b)
    test(r is None, "Anti-bruit", f"Rejet parasite '{b}'", "Ignoré", "Vérifier 02_filtre_alias.py")

for cmd in ("heure", "quelle date on est", "analyse", "cpu", "ram", "froid", "boost", "est-ce que je suis branché", "youtube", "chrome", "ouvre dossier", "souvenirs", "webia", "pdf", "planificateur", "coffre", "audit"):
    r, _ = filtre.filtrer(cmd)
    test(bool(r), "Commandes", f"Routage ordre : '{cmd}'", f"➔ {r}", f"Ajouter '{cmd}' dans variantes_utilisateur.txt")

tot = ok_cnt + err_cnt
score = int(ok_cnt * 100 / tot)
print(f"\n{B}╔════════════════════════════════════════════════════════════════════════════╗")
print(f"║  {V}✔ VERT : {ok_cnt:<3}{B}  |  {R if err_cnt else V}✘ ROUGE : {err_cnt:<3}{B}  |  FIABILITÉ RÉELLE : {score}%                     ║")
print(f"╚════════════════════════════════════════════════════════════════════════════╝{Z}")

if fixes:
    print(f"\n{R}🛠️  ANOMALIES RÉELLES DÉTECTÉES & COMMANDES DE CORRECTION :{Z}")
    for cat, lbl, det, fx in fixes:
        print(f"  {J}[{cat}]{Z} {lbl} ({det})\n     {V}➔ Action :{Z} {fx}")
else:
    print(f"\n  {V}🏆 AUCUNE ANOMALIE CACHÉE : SYSTÈME VÉRIFIÉ SANS COMPLAISANCE !{Z}\n")
