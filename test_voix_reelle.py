import os, importlib.util
ROOT = os.path.expanduser("~/tiffany")
spec = importlib.util.spec_from_file_location("f", ROOT+"/ear_modules/02_filtre_alias.py")
filtre = importlib.util.module_from_spec(spec); spec.loader.exec_module(filtre)
V, R, J, B, Z = "[92m", "[91m", "[93m", "[96m", "[0m"
bruits = ("tuk", "coque", "hum hum hum")
cmds = ("maillot","hestia","montre le volume a cinquante","pauvre dossier musique","ouvre minsk","noyau","testia","audit","analyse","heure","quelle date on est","meteo","froid","boost","zram","wifi","radar","aide","souvenirs","lireweb","cherche milk","ouvre dossier","ouvre bureau","telechargements","documents","volume up","next","pause","muet","nuit","jour","fenetres","bureau","next song","system check","cold mode","boost mode","turbo ram")
ok, err = 0, 0
print(f"\n{B}🎤 SIMULATION VOCALE INTÉGRALE (COMME AU MICRO){Z}\n")
for ph in bruits + cmds:
    res, direct = filtre.filtrer(ph)
    if ph in bruits:
        if res is None: ok += 1; print(f"  {V}✔ [ANTI-BRUIT]{Z} {ph} -> Ignoré")
        else: err += 1; print(f"  {R}✘ [ANTI-BRUIT]{Z} {ph} -> {res}")
    elif res:
        ok += 1; print(f"  {V}✔ [COMPRIS]{Z}    {ph:<28} ➔ {J}{res}{Z} ({'Direct' if direct else 'Console'})")
    else:
        err += 1; print(f"  {R}✘ [PERDU]{Z}      {ph} -> None")
print(f"\n{B}BILAN : {V}{ok}/{len(bruits)+len(cmds)} VALIDÉES{Z} | {R if err else V}{err} ÉCHEC{Z}\n")
