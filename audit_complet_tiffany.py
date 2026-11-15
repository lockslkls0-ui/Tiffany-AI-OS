import os, glob, time, shutil, subprocess, importlib.util
ROOT = os.path.expanduser("~/tiffany")
V, R, J, B, Z = "\033[92m", "\033[91m", "\033[93m", "\033[96m", "\033[0m"
ok_tot, err_tot = 0, 0
def check(cond, label, detail=""):
    global ok_tot, err_tot
    if cond: ok_tot += 1; print(f"  {V}✔ [OK]{Z}     {label} {J}{detail}{Z}")
    else: err_tot += 1; print(f"  {R}✘ [ERREUR]{Z} {label} {R}{detail}{Z}")

print(f"\n{B}🔬 BANC D ESSAI INTÉGRAL TIFFANY AI-OS v48.6{Z}\n")
sh = sorted(glob.glob(ROOT+"/*.sh") + glob.glob(ROOT+"/plugins/*.sh") + glob.glob(ROOT+"/ear_modules/*.sh"))
check(all(subprocess.run(["bash","-n",f],stderr=subprocess.DEVNULL).returncode==0 for f in sh), f"{len(sh)} scripts Bash vérifiés")
py = sorted(glob.glob(ROOT+"/*.py") + glob.glob(ROOT+"/ear_modules/*.py"))
check(all(subprocess.run(["python3","-m","py_compile",f],stderr=subprocess.DEVNULL).returncode==0 for f in py), f"{len(py)} moteurs Python compilés")
for nom, ch in [("Modèle Vosk FR", ROOT+"/voice/vosk-fr/vosk-model-small-fr-0.22"), ("Voix Siwis HD", "/home/user/tiffany/voice/fr_FR-siwis-medium.onnx"), ("Wrapper Voix", ROOT+"/bin/espeak-ng"), ("Dictionnaire Flash", ROOT+"/dictionnaire_flash.txt")]:
    check(os.path.exists(ch), nom)
spec = importlib.util.spec_from_file_location("f", ROOT+"/ear_modules/02_filtre_alias.py")
filtre = importlib.util.module_from_spec(spec); spec.loader.exec_module(filtre)
for ent, att, d_att in [("tuk",None,False),("bost","boost",True),("ouvre le dossier musique","ouvre le dossier musique",False)]:
    r, d = filtre.filtrer(ent)
    check(r==att and d==d_att, f"Routage vocal ('{ent}' -> {r})")
off = os.path.exists(os.path.expanduser("~/.config/tiffany/oreille_off"))
ps = subprocess.check_output(["ps","-eo","args"]).decode(errors="ignore")
check(off or ("03_moteur_ecoute.py" in ps and "arecord" in ps), "Oreille Vocale", "(Mode OFF volontaire)" if off else "(Active ON)")
check(subprocess.run(["systemctl","is-active","--quiet","ollama"]).returncode==0, "Service IA locale Ollama")
print(f"\n{B}BILAN : {V}✔ {ok_tot} RÉUSSIS{Z} | {R if err_tot else V}✘ {err_tot} ERREUR{Z}\n")
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
