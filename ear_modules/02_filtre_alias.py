import re
import os, difflib
ROOT = os.path.expanduser("~/tiffany")
ACT = {"next","skip","suivant","suivante","pause","play","stop","muet","silence","musique","radio","menu","panneau","cam","webcam","zone","nuit","jour","froid","boost","zram","turbo","backup","sauvegarde","instinct","fenetre","range","bureau","pilote","droite","gauche","monte","descends","clic","onglet","plein ecran","verrouille","oreille","tais-toi","chut","annule","stop ia","urgence"}
VERBES_RECHERCHE = ("ouvre ", "cherche ", "trouve ", "lance ", "lis ", "résume ", "resume ", "explique ", "crée ", "cree ", "écris ", "ecris ")
CORRECTIONS_VOSK = (
    (r"^pauvre\b", "ouvre"),
    (r"^oeuvres?\b", "ouvre"),
    (r"^ouvre le dossier\b", "ouvre dossier"),
    (r"pierre de claire|pierre declere", "pierre decker"),
    (r"^cent\s+([0-9]+)", r"son \1"),
)

def charger_alias():
    a = set(ACT)
    for fn in ("dictionnaire_flash.txt", "variantes_utilisateur.txt"):
        fp = os.path.join(ROOT, fn)
        if os.path.exists(fp):
            for l in open(fp, encoding="utf-8", errors="ignore"):
                if "|" in l and not l.startswith("#"):
                    a.add(l.split("|", 1).pop(0).strip().lower())
    return list(a)

def filtrer(brut):
    txt = brut.strip().lower()
    for pat, rep in CORRECTIONS_VOSK:
        txt = re.sub(pat, rep, txt)
    if len(txt) <= 2: return None, False
    if txt.startswith(VERBES_RECHERCHE):
        return txt, False
    al = charger_alias()
    if txt in al:
        return txt, (txt in ACT)
    if len(txt.split()) <= 3:
        pr = difflib.get_close_matches(txt, al, n=1, cutoff=0.82)
        if pr:
            m = pr.pop(0)
            return m, (m in ACT)
    if len(txt.split()) == 1:
        return None, False
    return txt, False
