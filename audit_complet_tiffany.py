import os, re, glob, time, shutil, subprocess, importlib.util
ROOT = os.path.expanduser("~/tiffany")
V, R, J, B, Z = "\033[92m", "\033[91m", "\033[93m", "\033[96m", "\033[0m"
ok_tot, err_tot, pannes = 0, 0, []
def check(cond, label, origine="", fix=""):
    global ok_tot, err_tot
    if cond: ok_tot += 1; print(f"  {V}✔ [OK]{Z}     {label}")
    else: err_tot += 1; print(f"  {R}✘ [ERREUR]{Z} {label}"); pannes.append((label, origine, fix))

print(f"\n{B}══════════════════════════════════════════════════════════════════\n   🔬 BANC D ESSAI INTÉGRAL + RADAR RAYONS X & AUTO-DIAGNOSTIC\n══════════════════════════════════════════════════════════════════{Z}")
print(f"\n{B}--- [1/5] SYNTAXE GLOBALE (TOUS DOSSIERS BASH & PYTHON) ---{Z}")
sh = [f for f in sorted(glob.glob(ROOT+"/**/*.sh", recursive=True)) if "/backup/" not in f]
for f in sh:
    res = subprocess.run(["bash","-n",f], capture_output=True, text=True)
    if res.returncode != 0: check(False, f"Syntaxe Bash : {os.path.basename(f)}", res.stderr.strip(), f"bash -n {f}")
check(True, f"{len(sh)} scripts Bash analysés")
py = [f for f in sorted(glob.glob(ROOT+"/**/*.py", recursive=True)) if "/backup/" not in f]
for f in py:
    res = subprocess.run(["python3","-m","py_compile",f], capture_output=True, text=True)
    check(res.returncode == 0, f"Python : {os.path.basename(f)}", res.stderr.strip(), f"python3 -m py_compile {f}")
print(f"\n{B}--- [2/5] MODÈLES VOCAUX, VOIX HD & OUTILS SYSTÈME ---{Z}")
for nom, ch, fix in [("Modèle Vosk FR", ROOT+"/voice/vosk-fr/vosk-model-small-fr-0.22", "Vérifier dossier voice/vosk-fr"), ("Voix Neuronale Siwis HD", "/home/user/Téléchargements/fr_FR-siwis-low.onnx", "find ~ -name *siwis*.onnx"), ("Wrapper Voix HD", ROOT+"/bin/espeak-ng", "chmod +x ~/tiffany/bin/espeak-ng"), ("Dictionnaire Flash", ROOT+"/dictionnaire_flash.txt", "Vérifier dictionnaire_flash.txt"), ("Variantes Utilisateur", ROOT+"/variantes_utilisateur.txt", "Vérifier variantes_utilisateur.txt"), ("Correcteur Phonétique", ROOT+"/correcteur_phonetique.sh", "chmod +x ~/tiffany/correcteur_phonetique.sh")]:
    check(bool(ch) and os.path.exists(ch), nom, f"Fichier introuvable : {ch}", fix)
for out in ("zenity","wmctrl","pactl","arecord","nemo","python3","git"):
    check(shutil.which(out) is not None, f"Outil système : {out}", f"Binaire {out} absent", f"sudo apt install -y {out}")

print(f"\n{B}--- [3/5] SIMULATION VOCALE, ANTI-BRUIT & ROUTAGE ---{Z}")
spec = importlib.util.spec_from_file_location("f", ROOT+"/ear_modules/02_filtre_alias.py")
filtre = importlib.util.module_from_spec(spec); spec.loader.exec_module(filtre)
for ent, att, d_att, desc in [("tuk",None,False,"Rejet mot seul"),("coque",None,False,"Rejet bruit"),("bost","boost",True,"Alias flou"),("froid","froid",True,"Raccourci froid"),("next","next",True,"Raccourci next"),("coucou","coucou",False,"Alias coucou"),("ouvre dossier","ouvre dossier",True,"Ouverture $HOME"),("ouvre le dossier musique","ouvre le dossier musique",False,"Recherche dossier"),("cherche mon rapport","cherche mon rapport",False,"Recherche fichier")]:
    r, d = filtre.filtrer(ent)
    check(r==att and d==d_att, f"{desc} ('{ent}' -> {r})", f"Obtenu ({r}, {d}) au lieu de ({att}, {d_att})", "Vérifier ~/tiffany/ear_modules/02_filtre_alias.py")

print(f"\n{B}--- [4/5] RADAR RAYONS X & ACCÈS SYSTÈME ---{Z}")
non_exec = [f for f in sh if not os.access(f, os.X_OK)]
check(len(non_exec)==0, "Permissions exécutables (+x) sur tous les .sh", f"Non exécutables : {non_exec}", "chmod +x ~/tiffany/**/*.sh")
off = os.path.exists(os.path.expanduser("~/.config/tiffany/oreille_off"))
ps = subprocess.check_output(["ps","-eo","args"]).decode(errors="ignore")
check(off or ("03_moteur_ecoute.py" in ps and "arecord" in ps), "Oreille Modulaire & Micro" + (" (Mode OFF)" if off else " (Actifs)"), "Processus oreille ou arecord arrêté", "systemctl --user restart tiffany-ear.service")
j_err = subprocess.check_output(["journalctl","--user","-u","tiffany-ear.service","-u","tiffany-watchdog.service","--since","2 minutes ago","-p","err","--no-pager"]).decode(errors="ignore").strip()
check(len(j_err)==0 or "No entries" in j_err, "Journaux systemd (0 erreur récente)", j_err.splitlines().pop() if j_err else "", "journalctl --user -u tiffany-ear.service -n 20")
check(subprocess.run(["systemctl","is-active","--quiet","ollama"]).returncode==0, "Service IA locale Ollama actif", "Service Ollama arrêté", "sudo systemctl restart ollama")
for nom, ch in [("Dossier Config", os.path.expanduser("~/.config/tiffany")), ("Service Oreille systemd", os.path.expanduser("~/.config/systemd/user/tiffany-ear.service")), ("Service Watchdog systemd", os.path.expanduser("~/.config/systemd/user/tiffany-watchdog.service")), ("Dépôt Git local", ROOT+"/.git")]:
    check(os.path.exists(ch), nom, f"Manquant : {ch}", f"mkdir -p {ch}")

print(f"\n{B}══════════════════════════════════════════════════════════════════\n  {V}✔ VALIDATIONS : {ok_tot}{Z}   |   {R if err_tot else V}✘ ERREURS CACHÉES : {err_tot}{Z}\n══════════════════════════════════════════════════════════════════")
if pannes:
    print(f"\n{R}🩺 DIAGNOSTIC DES ERREURS & COMMANDES DE RÉPARATION :{Z}")
    for lbl, orig, fix in pannes:
        print(f"  {J}• Erreur :{Z} {lbl}\n    {R}Origine :{Z} {orig}\n    {V}Réparation :{Z} {fix}")
else:
    print(f"  {V}🏆 AUCUNE ERREUR CACHÉE : SYSTÈME 100 % SAIN ET ALIGNÉ !{Z}\n")
