#!/usr/bin/env bash
python3 - "$1" << 'PYEOF'
import sys, re, os

t = sys.argv[1].strip().lower()
t = re.sub(r"^(tiffany|tifany|typhanie|tiff|stephanie|hey)\s+", "", t)

var_file = os.path.expanduser("~/tiffany/variantes_utilisateur.txt")
if os.path.exists(var_file):
    for l in open(var_file, encoding="utf-8", errors="ignore"):
        if "|" in l and l.lower().startswith(t + "|"):
            t = l.split("|", 1)[1].strip().lower()
            break

nombres = {"zero":"0","un":"1","une":"1","deux":"2","trois":"3","quatre":"4","cinq":"5","six":"6","sept":"7","huit":"8","neuf":"9","dix":"10","vingt":"20","trente":"30","quarante":"40","cinquante":"50","soixante":"60","soixante-dix":"70","quatre-vingt":"80","quatre-vingts":"80","quatre-vingt-dix":"90"}
t = re.sub(r"\b(cent|sans|sang|sont)\s+(dix|vingt|trente|quarante|cinquante|soixante|soixante-dix|quatre-vingt|quatre-vingts|quatre-vingt-dix|[0-9]+)\b", r"son ", t)
for k, v in nombres.items():
    t = re.sub(r"\b" + k + r"\b", v, t)
t = re.sub(r"\bcent\b", "100", t)

regles = [
    (r"\b(ces pays|c.?est paix eu|c.?est p u|c p u)\b", "cpu"),
    (r"^www\s+youtube$", "youtube"),
    (r"\b(montlucon|montluçon|monte le son|montre le volume|montre le son|mets le son|volume)\s*(a|au)?\s*([0-9]+)", r"son a "),
    (r"^son\s+([0-9]+)$", r"son a "),
    (r"\b(montlucon|montluçon|montre le volume|montre le son|monter le volume|monter le son)\b", "monte le son"),
    (r"\bmonter\s+(le\s+)?(volume|son)\b", "monte le son"),
    (r"\bbaisser\s+(le\s+)?(volume|son)\b", "baisse le son"),
    (r"\bpauvre\b", "ouvre"),
    (r"^(oeuvres?|ouvrez|ombre|chambre)\b", "ouvre"),
    (r"^qu.?une\b", "ouvre"),
    (r"^(ouvre|cherche)\s+(minsk|munich|monique|mic|mick|mille|mil|mec|manque|1000)\b", r" milk"),
    (r"\b(boss|boste|boust|booster|bouste)\b", "boost"),
    (r"\b(frais|froide|frois)\b", "froid"),
    (r"\b(rame|rames)\b", "ram"),
    (r"\b(rythme|rythmes|ritme|rythmebox)\b", "rhythmbox"),
    (r"\b(nexte|nekst|suivante)\b", "next"),
    (r"\b(pose|pauses)\b", "pause"),
    (r"\b(muette|muets)\b", "muet"),
    (r"\b(chuck|chute|chutes|shuut|shuuut)\b", "chut"),
    (r"\b(menue|menus)\b", "menu"),
    (r"\b(maillot|maillots|noix|noyer|noyaux)\b", "noyau"),
    (r"\b(hestia|bastia|festia|vestia|test il a|test ia|teste ia|test y a|casque y a|casque il a)\b", "testia"),
    (r"\b(web ia|web il a|web ya|web y a)\b", "webia"),
    (r"\b(lire web|lis web|lire ouais)\b", "lireweb"),
    (r"\b(souvenir|souvenire)\b", "souvenirs"),
    (r"\b(doc|docs)\b", "docteur"),
    (r".*(donne|dit|dis).*(heure|leur).*", "heure"),
    (r"\b(fenetre|fenêtres)\b", "fenetres"),
    (r"\b(webcam|web cam)\b", "cam"),
]
for pat, rep in regles:
    t = re.sub(pat, rep, t)
print(t)
PYEOF
