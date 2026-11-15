#!/usr/bin/env bash
TXT=$(echo "$1" | sed -E "s/^(tiffany|tifany|typhanie|tiff|stephanie|hey)[[:space:]]+//g")
VAR_FILE="$HOME/tiffany/variantes_utilisateur.txt"
if [ -f "$VAR_FILE" ]; then
    MATCH_VAR=$(grep -i "^${TXT}|" "$VAR_FILE" | head -n 1 | cut -d'|' -f2- | xargs)
    [ -n "$MATCH_VAR" ] && TXT="$MATCH_VAR"
fi
TXT=$(echo "$TXT" | sed -E "s/\bpauvre\b/ouvre/g; s/^oeuvres?\b/ouvre/g; s/^ouvrez\b/ouvre/g; s/^qu.?une\b/ouvre/g; s/pierre de claire|pierre declere/pierre decker/g")
TXT=$(echo "$TXT" | sed -E "s/^ouvre[[:space:]]+(minsk|munich|monique|mic|mick|mille|mil)\b/ouvre milk/g")
TXT=$(echo "$TXT" | sed -E "s/^son ([0-9]+)$/son a \1/" | sed -E '
    s/\b(cent|sans|sang|sont)[[:space:]]+(dix|vingt|trente|quarante|cinquante|soixante|soixante-dix|quatre-vingt|quatre-vingts|quatre-vingt-dix|[0-9]+)\b/son \2/g;
    s/\b(montlucon|montluçon|monte le son|montre le volume|montre le son|mets le son|volume)[[:space:]]*(a|au)?[[:space:]]*([0-9]+|dix|vingt|trente|quarante|cinquante|soixante|soixante-dix|quatre-vingt|quatre-vingts|quatre-vingt-dix)/son a \3/g;
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
