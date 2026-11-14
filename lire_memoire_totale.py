#!/usr/bin/env python3
import os, sys, glob, re

root = os.path.expanduser("~/tiffany")
home = os.path.expanduser("~")
question = " ".join(sys.argv[1:]).lower()

def lire_fin(chemin, n=10):
    if not os.path.exists(chemin):
        return ""
    with open(chemin, "r", encoding="utf-8", errors="ignore") as f:
        lignes = [l.strip() for l in f if l.strip()]
    return " | ".join(lignes[-n:])

surnom = lire_fin(os.path.join(root, "memory/surnom_utilisateur.txt"), 1) or "mon ange"
faits = lire_fin(os.path.join(root, "memory/long_term_facts.json"), 12)
journal = lire_fin(os.path.join(root, "memory/journal_de_bord.txt"), 8)
session = lire_fin(os.path.join(root, "logs/session_raw.txt"), 8)
web_memo = lire_fin(os.path.join(root, "memory/connaissances_web.txt"), 6)

# Recherche ciblée dans TOUS les dossiers Web-IA, Web et souvenirs selon les mots-clés de la question
mots_cles = [w for w in re.findall(r"[a-zàâäéèêëîïôöùûüç]{4,}", question) if w not in ("dans", "avec", "pour", "quoi", "comment", "pourquoi", "tiffany", "estce", "parle", "souviens", "rappelle", "quelle", "quel")]
extrait_cible = ""

if mots_cles:
    fichiers_archives = [
        os.path.join(root, "memory/long_term_facts.json"),
        os.path.join(root, "memory/journal_de_bord.txt"),
        os.path.join(root, "memory/connaissances_web.txt"),
    ]
    for pattern in ["*web*ia*", "*dossier*web*", "tiffany/connaissances/*"]:
        fichiers_archives.extend(glob.glob(os.path.join(home, "**", pattern), recursive=True))

    trouvailles = []
    for chemin in set(fichiers_archives):
        cibles = glob.glob(os.path.join(chemin, "*.*")) if os.path.isdir(chemin) else [chemin]
        for fpath in cibles:
            if not fpath.endswith((".txt", ".md", ".json")) or not os.path.isfile(fpath):
                continue
            try:
                contenu = open(fpath, "r", encoding="utf-8", errors="ignore").read()
                for ligne in contenu.splitlines():
                    if any(m in ligne.lower() for m in mots_cles) and len(ligne.strip()) > 8:
                        trouvailles.append(f"[{os.path.basename(fpath)}] {ligne.strip()[:160]}")
                        if len(trouvailles) >= 5:
                            break
            except Exception:
                pass
        if len(trouvailles) >= 5:
            break
    if trouvailles:
        extrait_cible = " || ".join(trouvailles)

infos = [
    "Createur_officiel=lockslkls (Interdiction d'utiliser le prenom civil)",
    f"Utilisateur_actuel={surnom}",
]
if extrait_cible:
    infos.append(f"ARCHIVES_TROUVEES_SUR_CE_SUJET={extrait_cible}")
if faits:
    infos.append(f"Souvenirs_graves={faits}")
if web_memo:
    infos.append(f"Savoir_Web_IA={web_memo}")
if journal:
    infos.append(f"Journal_sessions={journal}")
if session:
    infos.append(f"Fil_conversation_actuelle={session}")

print(" | ".join(infos))
