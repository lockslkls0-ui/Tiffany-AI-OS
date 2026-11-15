#!/usr/bin/env bash
TXT=$(echo "$1" | sed -E "s/^(tiffany|tifany|typhanie|tiff|stephanie|hey)[[:space:]]+//g")
VAR_FILE="$HOME/tiffany/variantes_utilisateur.txt"
if [ -f "$VAR_FILE" ]; then
    MATCH_VAR=$(grep -i "^${TXT}|" "$VAR_FILE" | head -n 1 | cut -d'|' -f2- | xargs)
    [ -n "$MATCH_VAR" ] && TXT="$MATCH_VAR"
fi
TXT=$(python3 -c 'import sys,re; t=sys.argv.pop(1); m={"zero":"0","un":"1","une":"1","deux":"2","trois":"3","quatre":"4","cinq":"5","six":"6","sept":"7","huit":"8","neuf":"9","dix":"10","vingt":"20","trente":"30","quarante":"40","cinquante":"50","soixante":"60","soixante-dix":"70","quatre-vingt":"80","quatre-vingts":"80","quatre-vingt-dix":"90","cent":"100"}; [t:=re.sub(r"\\b"+k+r"\\b",v,t) for k,v in m.items()]; print(t)' "$TXT")
TXT=$(echo "$TXT" | sed -E "s/\bpauvre\b/ouvre/g; s/^oeuvres?\b/ouvre/g; s/^ouvrez\b/ouvre/g; s/^qu.?une\b/ouvre/g; s/pierre de claire|pierre declere/pierre decker/g")
TXT=$(echo "$TXT" | sed -E "s/^ouvre[[:space:]]+(minsk|munich|monique|mic|mick|mille|mil)\b/ouvre milk/g")
TXT=$(echo "$TXT" | sed -E "s/^son ([0-9]+)$/son a \1/" | sed -E '
    s/\b(cent|sans|sang|sont)[[:space:]]+([0-9]+)\b/son \2/g;
    s/\b(montlucon|montluçon|monte le son|montre le volume|montre le son|mets le son|volume)[[:space:]]*(a|au)?[[:space:]]*([0-9]+)/son a \3/g;
    s/\b(montlucon|montluçon|montre le volume|montre le son|monter le volume|monter le son)\b/monte le son/g;
    s/\bmonter[[:space:]]+(le[[:space:]]+)?(volume|son)\b/monte le son/g;
    s/\bbaisser[[:space:]]+(le[[:space:]]+)?(volume|son)\b/baisse le son/g;
    s/\b(boss|boste|boust|booster|bouste)\b/boost/g;
    s/\b(frais|froide|frois)\b/froid/g;
    s/\b(rame|rames)\b/ram/g;
    s/\b(rythme|rythmes|ritme|rythmebox)\b/rhythmbox/g;
    s/\b(nexte|nekst|suivante)\b/next/g;
    s/\b(pose|pauses)\b/pause/g;
    s/\b(muette|muets)\b/muet/g;
    s/\b(chuck|chute|chutes|shuut|shuuut)\b/chut/g;
    s/\b(menue|menus)\b/menu/g;
    s/\b(maillot|maillots|noix|noyer|noyaux)\b/noyau/g;
    s/\b(hestia|bastia|festia|vestia|test il a|test ia|teste ia|test y a|casque y a|casque il a)\b/testia/g;
    s/\b(web ia|web il a|web ya|web y a)\b/webia/g;
    s/\b(lire web|lis web|lire ouais)\b/lireweb/g;
    s/\b(souvenir|souvenire)\b/souvenirs/g;
    s/\b(doc|docs)\b/docteur/g;
    s/.*(donne|dit|dis).*(heure|leur).*/heure/g;
    s/\b(fenetre|fenêtres)\b/fenetres/g;
    s/\b(webcam|web cam)\b/cam/g
')
echo "$TXT"
