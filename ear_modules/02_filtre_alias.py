import os, subprocess, difflib
ROOT = os.path.expanduser("~/tiffany")
ACT = {"next","skip","suivant","suivante","pause","play","stop","muet","silence","musique","radio","menu","panneau","cam","webcam","zone","nuit","jour","froid","boost","zram","turbo","backup","sauvegarde","instinct","fenetre","range","bureau","pilote","droite","gauche","monte","descends","clic","onglet","plein ecran","verrouille","oreille","tais-toi","chut","annule","stop ia","urgence"}
VERBES_RECHERCHE = ("ouvre ", "cherche ", "trouve ", "lance ", "lis ", "résume ", "resume ", "explique ", "crée ", "cree ", "écris ", "ecris ")

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
    cs = os.path.join(ROOT, "correcteur_phonetique.sh")
    if os.path.exists(cs):
        try:
            o = subprocess.check_output(["bash", cs, txt], stderr=subprocess.DEVNULL, timeout=1).decode().strip().lower()
            if o: txt = o
        except Exception: pass
    if len(txt) <= 2: return None, False

    # 1. Si c est une vraie demande d ouverture/recherche, on laisse le cerveau principal chercher le fichier/dossier
    if txt.startswith(VERBES_RECHERCHE):
        return txt, False

    al = charger_alias()
    # 2. Alias exact (ex: coucou, boost, froid, next, menu...)
    if txt in al:
        return txt, (txt in ACT)

    # 3. Rapprochement flou uniquement sur les commandes courtes (1 a 3 mots)
    if len(txt.split()) <= 3:
        pr = difflib.get_close_matches(txt, al, n=1, cutoff=0.78)
        if pr:
            m = pr.pop(0)
            return m, (m in ACT)

    # 4. Rejette tout mot seul inconnu (anti-bruit)
    if len(txt.split()) == 1:
        return None, False

    return txt, False
