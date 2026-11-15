import os, subprocess, difflib
ROOT = os.path.expanduser("~/tiffany")
ACT = {"next","skip","suivant","suivante","pause","play","muet","silence","musique","radio","menu","panneau","cam","webcam","zone","nuit","jour","froid","boost","zram","turbo","backup","sauvegarde","ouvre dossier","telechargements","documents","parametres","mes fichiers","instinct","fenetre","range","bureau","pilote","droite","gauche","monte","descends","clic","onglet","plein ecran","verrouille","oreille","tais-toi","chut","annule","stop ia","urgence"}
VERBES_RECHERCHE = ("ouvre ", "cherche ", "trouve ", "lance ", "lis ", "résume ", "resume ", "explique ", "crée ", "cree ", "écris ", "ecris ")

def charger_alias():
    a = set(ACT)
    for fn in ("dictionnaire_flash.txt", "variantes_utilisateur.txt", "actions_terminal/dictionnaire_ia.txt", "dictionnaire_ia.txt"):
        fp = os.path.join(ROOT, fn)
        if os.path.exists(fp):
            for l in open(fp, encoding="utf-8", errors="ignore"):
                if "|" in l and not l.startswith("#"):
                    cle = l.split("|", 1).pop(0).strip().lower()
                    if cle and not cle.startswith("-"): a.add(cle)
    act_dir = os.path.join(ROOT, "actions_terminal")
    if os.path.isdir(act_dir):
        for sh in os.listdir(act_dir):
            if sh.endswith(".sh"):
                for l in open(os.path.join(act_dir, sh), encoding="utf-8", errors="ignore"):
                    if l.startswith("# TERM_KEY:"): a.add(l.split(":", 1).pop(1).strip().lower())
    return list(a)

def filtrer(brut):
    txt = brut.strip().lower()
    cs = os.path.join(ROOT, "correcteur_phonetique.sh")
    if os.path.exists(cs):
        try:
            o = subprocess.check_output(["bash", cs, txt], stderr=subprocess.DEVNULL, timeout=1).decode().strip().lower()
            if o: txt = o
        except Exception: pass
    mots = txt.split()
    if all(w in {"hum","euh","heu","hein","ah","oh","mh","hmm","oui","non","ok","et","le","la","de"} for w in mots):
        return None, False
    if txt.startswith("non ") and len(txt.split()) <= 3: return None, False
    if len(txt) <= 2: return None, False
    if txt == "ouvre dossier": return txt, True
    if txt.startswith(VERBES_RECHERCHE): return txt, False
    al = charger_alias()
    if txt in al: return txt, (txt in ACT)
    if len(txt.split()) <= 3:
        pr = difflib.get_close_matches(txt, al, n=1, cutoff=0.80)
        if pr:
            m = pr.pop(0)
            return m, (m in ACT)
    if len(txt.split()) == 1: return None, False
    return txt, False
