#!/usr/bin/env bash
IN="$1"
OUT=$(python3 -c '
import sys, re, os
t = sys.argv[1].strip().lower()
t = re.sub(r"^(tiffany|tifany|typhanie|tiff|stephanie|hey)\s+", "", t)
n = {"zero":"0","un":"1","une":"1","deux":"2","trois":"3","quatre":"4","cinq":"5","six":"6","sept":"7","huit":"8","neuf":"9","dix":"10","vingt":"20","trente":"30","quarante":"40","cinquante":"50","soixante":"60","soixante-dix":"70","quatre-vingt":"80","quatre-vingts":"80","quatre-vingt-dix":"90"}
t = re.sub(r"\b(cent|sans|sang|sont)\s+(dix|vingt|trente|quarante|cinquante|soixante|soixante-dix|quatre-vingt|quatre-vingts|quatre-vingt-dix|[0-9]+)\b", r"son \2", t)
for k, v in n.items(): t = re.sub(r"\b" + k + r"\b", v, t)
t = re.sub(r"\bcent\b", "100", t)
r = [(r"\bactive\s+le[çc]on\b", "active le son"), (r"\b(son|sont|sans)\s+(sang|cent)\b", "son a 100"), (r"\bsont\s+(a|à)\s+([0-9]+)\b", r"son a \2"), (r".*(montre le volume|montre le son|volume|son)\s*(a|au)?\s*([0-9]+).*", r"son a \3"), (r"\b(ces pays|c.?est paix eu|c.?est p u|c p u)\b", "cpu"), (r"^(www\s+youtube|ouvre\s+youtube)$", "youtube"), (r"^(oeuvres?|ouvrez|ombre|chambre|onze|evreux|heureux|ouvrent|pour|tu)\s+(google|chrome|internet)$", "chrome"), (r"^ouvre\s+(google|chrome|internet|navigateur)$", "chrome"), (r"\b(montlucon|montluçon|monter le volume|monter le son)\b", "monte le son"), (r"\bmonter\s+(le\s+)?(volume|son)\b", "monte le son"), (r"\bbaisser\s+(le\s+)?(volume|son)\b", "baisse le son"), (r"\bpauvre\b", "ouvre"), (r"^(oeuvres?|ouvrez|ombre|chambre|onze|evreux|heureux)\b", "ouvre"), (r"^qu.?une\b", "ouvre"), (r"^(ouvre|cherche)\s+(minsk|munich|monique|mic|mick|mille|mil|mec|manque|1000)\b", r"\1 milk"), (r"\b(boss|boste|boust|booster|bouste)\b", "boost"), (r"\b(frais|froide|frois)\b", "froid"), (r"\b(rame|rames)\b", "ram"), (r"\b(rythme|rythmes|ritme|rythmebox)\b", "rhythmbox"), (r"\b(next song|nexte|nekst|suivante)\b", "next"), (r"\b(pose|pauses)\b", "pause"), (r"\b(muette|muets)\b", "muet"), (r"\b(chuck|chute|chutes|shuut|shuuut)\b", "chut"), (r"\b(menue|menus)\b", "menu"), (r"\b(maillot|maillots|noix|noyer|noyaux)\b", "noyau"), (r"\b(hestia|bastia|festia|vestia|test il a|test ia|teste ia|test y a|casque y a|casque il a)\b", "testia"), (r"\b(web ia|web il a|web ya|web y a)\b", "webia"), (r"\b(lire web|lis web|lire ouais)\b", "lireweb"), (r"\b(souvenir|souvenire)\b", "souvenirs"), (r"\b(doc|docs)\b", "docteur"), (r".*(donne|dit|dis).*(heure|leur).*", "heure"), (r"\b(fenetre|fenêtres)\b", "fenetres"), (r"\b(webcam|web cam)\b", "cam")]
for pat, rep in r: t = re.sub(pat, rep, t)
print(t)
' "$IN" 2>/dev/null)
[ -n "$OUT" ] && echo "$OUT" || echo "$IN"
