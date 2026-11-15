import os, re, glob, time, shutil, subprocess, importlib.util
ROOT = os.path.expanduser("~/tiffany")
V, R, J, B, Z = "\033[92m", "\033[91m", "\033[93m", "\033[96m", "\033[0m"
ok_tot, err_tot = 0, 0
def check(cond, label, detail=""):
    global ok_tot, err_tot
    if cond: ok_tot += 1; print(f"  {V}✔ [OK]{Z}     {label} {J}{detail}{Z}")
    else: err_tot += 1; print(f"  {R}✘ [ERREUR]{Z} {label} {R}{detail}{Z}")

print(f"\n{B}══════════════════════════════════════════════════════════════════\n   🔬 BANC D ESSAI INTÉGRAL + RADAR RAYONS X (TIFFANY AI-OS v48.6)\n══════════════════════════════════════════════════════════════════{Z}")
print(f"\n{B}--- [1/5] SYNTAXE GLOBALE (TOUS DOSSIERS BASH & PYTHON) ---{Z}")
sh = sorted(glob.glob(ROOT+"/**/*.sh", recursive=True))
sh = [f for f in sh if "/backup/" not in f]
err_sh = [os.path.basename(f) for f in sh if subprocess.run(["bash","-n",f],stderr=subprocess.DEVNULL).returncode != 0]
check(len(err_sh)==0, f"{len(sh)} scripts Bash analysés", f"Erreurs: {err_sh}" if err_sh else "(0 erreur)")
py = sorted(glob.glob(ROOT+"/**/*.py", recursive=True))
py = [f for f in py if "/backup/" not in f]
err_py = [os.path.basename(f) for f in py if subprocess.run(["python3","-m","py_compile",f],stderr=subprocess.DEVNULL).returncode != 0]
check(len(err_py)==0, f"{len(py)} scripts Python compilés", f"Erreurs: {err_py}" if err_py else "(0 erreur)")
print(f"\n{B}--- [2/5] MODÈLES VOCAUX, VOIX HD & OUTILS SYSTÈME ---{Z}")
for nom, ch in [("Modèle Vosk FR", ROOT+"/voice/vosk-fr/vosk-model-small-fr-0.22"), ("Voix Neuronale Siwis HD", "/home/user/Téléchargements/fr_FR-siwis-low.onnx"), ("Wrapper Voix HD", ROOT+"/bin/espeak-ng"), ("Dictionnaire Flash", ROOT+"/dictionnaire_flash.txt"), ("Variantes Utilisateur", ROOT+"/variantes_utilisateur.txt")]:
    check(bool(ch) and os.path.exists(ch), nom)
for out in ("zenity","wmctrl","pactl","arecord","nemo","python3","git"):
    check(shutil.which(out) is not None, f"Binaire système : {out}")

print(f"\n{B}--- [3/5] SIMULATION VOCALE, ANTI-BRUIT & ROUTAGE ---{Z}")
spec = importlib.util.spec_from_file_location("f", ROOT+"/ear_modules/02_filtre_alias.py")
filtre = importlib.util.module_from_spec(spec); spec.loader.exec_module(filtre)
for ent, att, d_att, desc in [("tuk",None,False,"Rejet mot seul"),("coque",None,False,"Rejet bruit"),("bost","boost",True,"Alias flou"),("ouvre dossier","ouvre dossier",True,"Ouverture $HOME"),("ouvre le dossier musique","ouvre dossier musique",False,"Recherche dossier")]:
    r, d = filtre.filtrer(ent)
    check(r==att and d==d_att, f"{desc} ('{ent}' -> {r})")

print(f"\n{B}--- [4/5] RADAR RAYONS X : ERREURS CACHÉES, DROITS & SERVICES ---{Z}")
non_exec = [os.path.basename(f) for f in sh if not os.access(f, os.X_OK)]
check(len(non_exec)==0, "Permissions exécutables (+x) sur tous les .sh", f"Manquants: {non_exec}" if non_exec else "")
off = os.path.exists(os.path.expanduser("~/.config/tiffany/oreille_off"))
ps = subprocess.check_output(["ps","-eo","args"]).decode(errors="ignore")
check(off or ("03_moteur_ecoute.py" in ps and "arecord" in ps), "Oreille Modulaire & Micro", "(Mode OFF)" if off else "(Actifs)")
j_err = subprocess.check_output(["journalctl","--user","-u","tiffany-ear.service","-u","tiffany-watchdog.service","--since","2 minutes ago","-p","err","--no-pager"]).decode(errors="ignore").strip()
check(len(j_err)==0 or "No entries" in j_err, "Journaux systemd (0 erreur sur les 2 dernières min)", j_err.splitlines()[-1] if j_err else "")
check(subprocess.run(["systemctl","is-active","--quiet","ollama"]).returncode==0, "Service IA locale Ollama actif")

print(f"\n{B}--- [5/5] ACCÈS SYSTÈME, MÉMOIRE & SERVICES ---{Z}")
for nom, ch in [("Dossier Config (~/.config/tiffany)", os.path.expanduser("~/.config/tiffany")), ("Service Oreille systemd", os.path.expanduser("~/.config/systemd/user/tiffany-ear.service")), ("Service Watchdog systemd", os.path.expanduser("~/.config/systemd/user/tiffany-watchdog.service")), ("Dépôt Git local (.git)", ROOT+"/.git")]:
    check(os.path.exists(ch), nom)
check(os.access(ROOT, os.W_OK), "Accès écriture dossier ~/tiffany")
check(subprocess.run(["systemctl","--user","is-active","--quiet","tiffany-ear.service"]).returncode==0, "Service tiffany-ear.service actif")

print(f"\n{B}══════════════════════════════════════════════════════════════════\n  {V}✔ VALIDATIONS : {ok_tot}{Z}   |   {R if err_tot else V}✘ ERREURS CACHÉES : {err_tot}{Z}\n══════════════════════════════════════════════════════════════════\n")
print(f"\n{B}--- [3/6] MODÈLES VOCAUX, AUDIO & BINAIRES ---{Z}")
for nom, ch in [("Modèle Vosk FR", ROOT+"/voice/vosk-fr/vosk-model-small-fr-0.22"), ("Voix Neuronale Siwis HD", ROOT+"/voice/piper/fr_FR-siwis-medium.onnx"), ("Wrapper Voix HD", ROOT+"/bin/espeak-ng"), ("Dictionnaire Flash", ROOT+"/dictionnaire_flash.txt"), ("Variantes Utilisateur", ROOT+"/variantes_utilisateur.txt"), ("Correcteur Phonétique", ROOT+"/correcteur_phonetique.sh")]:
    check(os.path.exists(ch), nom)
for outil in ("zenity", "wmctrl", "pactl", "arecord", "python3", "git"):
    check(shutil.which(outil) is not None, f"Outil système : {outil}")
print(f"\n{B}--- [4/6] SIMULATION VOCALE, ANTI-BRUIT & ROUTAGE ---{Z}")
spec = importlib.util.spec_from_file_location("f", ROOT+"/ear_modules/02_filtre_alias.py")
filtre = importlib.util.module_from_spec(spec); spec.loader.exec_module(filtre)
cas = [("tuk", None, False, "Rejet mot seul parasite"), ("coque", None, False, "Rejet bruit ambigu"), ("bost", "boost", True, "Correction floue alias"), ("froid", "froid", True, "Raccourci thermique"), ("next", "next", True, "Raccourci multimédia"), ("coucou", "coucou", False, "Alias conversationnel"), ("ouvre le dossier musique", "ouvre le dossier musique", False, "Priorité recherche dossier"), ("cherche mon rapport", "cherche mon rapport", False, "Priorité recherche fichier")]
for entree, attendu, dir_att, desc in cas:
    res, direct = filtre.filtrer(entree)
    check(res == attendu and direct == dir_att, f"{desc} ('{entree}' -> {res})")
print(f"\n{B}--- [5/6] PROCESSUS ACTIFS & SENTINELLES ---{Z}")
ps_out = subprocess.check_output(["ps", "-eo", "args"]).decode(errors="ignore")
check("03_moteur_ecoute.py" in ps_out, "Oreille Modulaire active en arrière-plan")
check("arecord" in ps_out, "Flux micro ALSA/Pulse actif")
check(subprocess.run(["systemctl", "is-active", "--quiet", "ollama"]).returncode == 0, "Service IA locale Ollama actif")
print(f"\n{B}══════════════════════════════════════════════════════════════════{Z}")
print(f"  {V}✔ TESTS RÉUSSIS : {ok_tot}{Z}   |   {R if err_tot else V}✘ ERREURS : {err_tot}{Z}")
print(f"{B}══════════════════════════════════════════════════════════════════{Z}\n")
