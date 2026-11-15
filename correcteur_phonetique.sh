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
t = re.sub(r"(cent|sans|sang|sont)\s+(dix|vingt|trente|quarante|cinquante|soixante|soixante-dix|quatre-vingt|quatre-vingts|quatre-vingt-dix|[0-9]+)", r"son ", t)
for k, v in nombres.items():
    t = re.sub(r"" + k + r"", v, t)
t = re.sub(r"cent", "100", t)

regles = [
    (r"(montlucon|montluçon|monte le son|montre le volume|montre le son|mets le son|volume)\s*(a|au)?\s*([0-9]+)", r"son a "),
    (r"^son\s+([0-9]+)$", r"son a "),
    (r"(montlucon|montluçon|montre le volume|montre le son|monter le volume|monter le son)", "monte le son"),
    (r"monter\s+(le\s+)?(volume|son)", "monte le son"),
    (r"baisser\s+(le\s+)?(volume|son)", "baisse le son"),
    (r"pauvre", "ouvre"),
    (r"^(oeuvres?|ouvrez|ombre|chambre)", "ouvre"),
    (r"^qu.?une", "ouvre"),
    (r"^(ouvre|cherche)\s+(minsk|munich|monique|mic|mick|mille|mil|mec|manque|1000)", r" milk"),
    (r"(boss|boste|boust|booster|bouste)", "boost"),
    (r"(frais|froide|frois)", "froid"),
    (r"(rame|rames)", "ram"),
    (r"(rythme|rythmes|ritme|rythmebox)", "rhythmbox"),
    (r"(nexte|nekst|suivante)", "next"),
    (r"(pose|pauses)", "pause"),
    (r"(muette|muets)", "muet"),
    (r"(chuck|chute|chutes|shuut|shuuut)", "chut"),
    (r"(menue|menus)", "menu"),
    (r"(maillot|maillots|noix|noyer|noyaux)", "noyau"),
    (r"(hestia|bastia|festia|vestia|test il a|test ia|teste ia|test y a|casque y a|casque il a)", "testia"),
    (r"(web ia|web il a|web ya|web y a)", "webia"),
    (r"(lire web|lis web|lire ouais)", "lireweb"),
    (r"(souvenir|souvenire)", "souvenirs"),
    (r"(doc|docs)", "docteur"),
    (r".*(donne|dit|dis).*(heure|leur).*", "heure"),
    (r"(fenetre|fenêtres)", "fenetres"),
    (r"(webcam|web cam)", "cam"),
]
for pat, rep in regles:
    t = re.sub(pat, rep, t)
print(t)
PYEOF
