#!/usr/bin/env python3
import os, subprocess, importlib.util

ROOT = os.path.expanduser("~/tiffany")
V, R, J, B, C, G, Z = "\033[92m", "\033[91m", "\033[93m", "\033[96m", "\033[95m", "\033[90m", "\033[0m"

spec = importlib.util.spec_from_file_location("f", os.path.join(ROOT, "ear_modules/02_filtre_alias.py"))
filtre = importlib.util.module_from_spec(spec)
spec.loader.exec_module(filtre)

# 1. Test anti-bruit (doivent être rejetés silencieusement -> None)
bruits = [
    "hum", "euh", "tuk", "coque", "ah", "oh", "et", "le", "non merci", "oui", "ok"
]

# 2. Test complet des commandes vocales naturelles (toutes catégories)
commandes = [
    # Temps & Infos
    ("quelle heure il est", "Heure"),
    ("quelle date on est", "Date"),
    ("quel temps il fait", "Météo"),
    # Matériel & Diagnostic
    ("analyse", "Analyse matérielle"),
    ("etat du cpu", "Diagnostic CPU"),
    ("comment va la ram", "État RAM"),
    ("est-ce que je suis branché", "Batterie & Secteur"),
    ("ca chauffe", "Température CPU"),
    ("age de mon disque dur", "Santé SMART disque"),
    # Refroidissement & Performance
    ("mode froid", "Refroidissement CPU"),
    ("mets le boost", "Pleine puissance CPU"),
    ("turbo ram", "Compression ZRAM"),
    ("purge la ram", "Nettoyage mémoire"),
    # Audio & Multimédia
    ("monte le son", "Volume +15%"),
    ("baisse le son", "Volume -15%"),
    ("son a 50", "Volume précis 50%"),
    ("coupe le son", "Mode muet"),
    ("allume la musique", "Lancer Rhythmbox"),
    ("chanson suivante", "Piste suivante"),
    ("mets sur pause", "Pause / Lecture"),
    ("allume la radio", "Lancer Radio"),
    ("stop radio", "Couper Radio"),
    # Navigation, Fichiers & Fenêtres
    ("ouvre google", "Ouvrir Google Chrome"),
    ("ouvre youtube", "Ouvrir YouTube"),
    ("ouvre dossier", "Dossier personnel"),
    ("ouvre le dossier musique", "Dossier Musique"),
    ("telechargements", "Dossier Téléchargements"),
    ("cherche rapport", "Recherche fichier"),
    ("range les fenetres", "Partage écran 50/50"),
    ("montre le bureau", "Dégager le bureau"),
    # Outils IA, Mémoire & Sécurité
    ("ouvre le menu", "Panneau Tiffany"),
    ("de quoi tu te souviens", "Mémoire & Souvenirs"),
    ("webia", "Recherche Web-IA"),
    ("lire un pdf", "Lecture document PDF"),
    ("planificateur", "Planificateur & Réveils"),
    ("cree un coffre", "Coffre-fort chiffré 7z"),
    ("audit", "Banc d'essai fonctionnel"),
    ("noyau", "Inventaire noyau"),
    ("testia", "Stress test IA"),
    # Contrôle & Arrêt
    ("arrete de reflechir", "Stopper réflexion IA"),
    ("chut", "Stopper la voix"),
    ("merci", "Politesse / Réflexe"),
    ("bonjour", "Salutation")
]

print(f"\n{B}╔══════════════════════════════════════════════════════════════════════════╗")
print(f"║     🔇 TEST VOCAL INTÉGRAL SILENCIEUX — ANTI-BRUIT & 43 ORDRES VOCAUX    ║")
print(f"╚══════════════════════════════════════════════════════════════════════════╝{Z}\n")

ok_bruit, err_bruit = 0, 0
print(f"{C}▶ [1/2] TEST FILTRE ANTI-BRUIT & PARASITES MICRO ({len(bruits)} cas){Z}")
for b in bruits:
    res, _ = filtre.filtrer(b)
    if res is None:
        ok_bruit += 1
        print(f"  {V}✔ [REJETÉ]{Z}  '{b:<22}' ➔ Ignoré proprement")
    else:
        err_bruit += 1
        print(f"  {R}✘ [PASSÉ ]{Z}  '{b:<22}' ➔ Déclenché par erreur : '{res}'")

ok_cmd, err_cmd = 0, 0
print(f"\n{C}▶ [2/2] TEST RECONNAISSANCE & ROUTAGE VOCAL ({len(commandes)} commandes){Z}")
for phrase, cat in commandes:
    res, direct = filtre.filtrer(phrase)
    if res:
        ok_cmd += 1
        mode = "Direct (<0.1s)" if direct else "Aiguilleur"
        print(f"  {V}✔ [VERT  ]{Z}  '{phrase:<28}' ➔ {J}{res:<26}{Z} {G}[{cat} | {mode}]{Z}")
    else:
        err_cmd += 1
        print(f"  {R}✘ [ROUGE ]{Z}  '{phrase:<28}' ➔ {R}Non reconnu ({cat}){Z}")

tot_ok = ok_bruit + ok_cmd
tot_all = len(bruits) + len(commandes)
score = int(tot_ok * 100 / tot_all)

print(f"\n{B}╔══════════════════════════════════════════════════════════════════════════╗")
print(f"║  {V}✔ VALIDÉS : {tot_ok}/{tot_all:<3}{B}  |  {R if (err_bruit+err_cmd) else V}✘ ÉCHECS : {err_bruit+err_cmd:<3}{B}  |  PRÉCISION VOCALE : {score}%         ║")
print(f"╚══════════════════════════════════════════════════════════════════════════╝{Z}\n")
