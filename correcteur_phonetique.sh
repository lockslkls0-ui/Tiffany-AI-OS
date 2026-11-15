#!/usr/bin/env bash
TXT=$(echo "$1" | sed -E "s/^(tiffany|tifany|typhanie|tiff|stephanie|hey)[[:space:]]+//g")
VAR_FILE="$HOME/tiffany/variantes_utilisateur.txt"
if [ -f "$VAR_FILE" ]; then
    MATCH_VAR=$(grep -i "^${TXT}|" "$VAR_FILE" | head -n 1 | cut -d'|' -f2- | xargs)
    [ -n "$MATCH_VAR" ] && TXT="$MATCH_VAR"
fi
TXT=$(echo "$TXT" | sed -E '
    s/(cent|sans|sang|sont)[[:space:]]+(dix|vingt|trente|quarante|cinquante|soixante|soixante-dix|quatre-vingt|quatre-vingts|quatre-vingt-dix|[0-9]+)/son /g;
    s/(montlucon|montluçon|monte le son|montre le volume|montre le son|mets le son|volume)[[:space:]]*(a|au)?[[:space:]]*([0-9]+|dix|vingt|trente|quarante|cinquante|soixante|soixante-dix|quatre-vingt|quatre-vingts|quatre-vingt-dix)/son a /g;
')
TXT=$(python3 -c 'import sys,re; t=sys.argv.pop(1); m={"zero":"0","un":"1","une":"1","deux":"2","trois":"3","quatre":"4","cinq":"5","six":"6","sept":"7","huit":"8","neuf":"9","dix":"10","vingt":"20","trente":"30","quarante":"40","cinquante":"50","soixante":"60","soixante-dix":"70","quatre-vingt":"80","quatre-vingts":"80","quatre-vingt-dix":"90","cent":"100"};
for k,v in m.items(): t=re.sub(r""+k+r"",v,t)
print(t)' "$TXT")
TXT=$(echo "$TXT" | sed -E "s/\bpauvre\b/ouvre/g; s/^oeuvres?\b/ouvre/g; s/^ouvrez\b/ouvre/g; s/^qu.?une\b/ouvre/g; s/^(ombre|chambre)\b/ouvre/g; s/pierre de claire|pierre declere/pierre decker/g")
TXT=$(echo "$TXT" | sed -E "s/^(ouvre|cherche)[[:space:]]+(minsk|munich|monique|mic|mick|mille|mil|mec|manque|1000)\b/\1 milk/g")
TXT=$(echo "$TXT" | sed -E "s/^son ([0-9]+)$/son a \1/" | sed -E '
    s/(montlucon|montluçon|montre le volume|montre le son|monter le volume|monter le son)/monte le son/g;
    s/monter[[:space:]]+(le[[:space:]]+)?(volume|son)/monte le son/g;
    s/baisser[[:space:]]+(le[[:space:]]+)?(volume|son)/baisse le son/g;
    s/(boss|boste|boust|booster|bouste)/boost/g;
    s/(frais|froide|frois)/froid/g;
    s/(rame|rames)/ram/g;
    s/(rythme|rythmes|ritme|rythmebox)/rhythmbox/g;
    s/(nexte|nekst|suivante)/next/g;
    s/(pose|pauses)/pause/g;
    s/(muette|muets)/muet/g;
    s/(chuck|chute|chutes|shuut|shuuut)/chut/g;
    s/(menue|menus)/menu/g;
    s/(maillot|maillots|noix|noyer|noyaux)/noyau/g;
    s/(hestia|bastia|festia|vestia|test il a|test ia|teste ia|test y a|casque y a|casque il a)/testia/g;
    s/(web ia|web il a|web ya|web y a)/webia/g;
    s/(lire web|lis web|lire ouais)/lireweb/g;
    s/(souvenir|souvenire)/souvenirs/g;
    s/(doc|docs)/docteur/g;
    s/.*(donne|dit|dis).*(heure|leur).*/heure/g;
    s/(fenetre|fenêtres)/fenetres/g;
    s/(webcam|web cam)/cam/g
')
echo "$TXT"
