import os, subprocess, difflib
ROOT = os.path.expanduser("~/tiffany")
ACT = {"next","skip","suivant","suivante","pause","play","stop","muet","silence","musique","radio","menu","panneau","cam","webcam","zone","nuit","jour","froid","boost","zram","turbo","backup","sauvegarde","instinct","fenetre","range","bureau","chrome","youtube","pilote","droite","gauche","monte","descends","clic","onglet","plein ecran","verrouille","oreille","tais-toi","chut","annule","stop ia","urgence"}
def charger_alias():
    a = set(ACT)
    for fn in ("dictionnaire_flash.txt", "variantes_utilisateur.txt"):
        fp = os.path.join(ROOT, fn)
        if os.path.exists(fp):
            for l in open(fp, encoding="utf-8", errors="ignore"):
                if "|" in l and not l.startswith("#"): a.add(l.split("|",1).pop(0).strip().lower())
    return list(a)
def filtrer(brut):
    txt = brut.strip().lower()
    cs = os.path.join(ROOT, "correcteur_phonetique.sh")
    if os.path.exists(cs):
        try:
            o = subprocess.check_output(["bash", cs, txt], stderr=subprocess.DEVNULL, timeout=1).decode().strip().lower()
            if o: txt = o
        except Exception: pass
    if len(txt) <= 2: return None, False
    al = charger_alias()
    if txt in al: return txt, True
    pr = difflib.get_close_matches(txt, al, n=1, cutoff=0.70)
    if pr: return pr.pop(0), True
    for x in al:
        if len(x) >= 4 and (x == txt or txt.startswith(x+" ") or txt.endswith(" "+x)): return txt, True
    if len(txt.split()) == 1: return None, False
    return txt, False
