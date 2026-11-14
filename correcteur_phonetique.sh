#!/usr/bin/env bash
TXT=$(echo "$1" | sed -E "s/^(tiffany|tifany|typhanie|tiff|stephanie)[[:space:]]+//g")
# 0. Appliquer les variantes personnalisées et traductions multilingues de l'utilisateur
VAR_FILE="$HOME/tiffany/variantes_utilisateur.txt"
if [ -f "$VAR_FILE" ]; then
    MATCH_VAR=$(grep -i "^${TXT}|" "$VAR_FILE" | head -n 1 | cut -d'|' -f2- | xargs)
    [ -n "$MATCH_VAR" ] && TXT="$MATCH_VAR"
fi


# Corriger d'abord les confusions 'cent/sans' devant un nombre (ex: "cent cinquante" -> "son cinquante")
TXT=$(echo "$TXT" | sed -E "s/^son ([0-9]+)$/son a \1/" | sed -E '
    s/\b(cent|sans|sang|sont)[[:space:]]+(dix|vingt|trente|quarante|cinquante|soixante|soixante-dix|quatre-vingt|quatre-vingts|quatre-vingt-dix|[0-9]+)\b/son \2/g;
    s/\b(montlucon|montluçon|monte le son|montre le volume|montre le son|mets le son|volume)[[:space:]]*(a|au)?[[:space:]]*([0-9]+|dix|vingt|trente|quarante|cinquante|soixante|soixante-dix|quatre-vingt|quatre-vingts|quatre-vingt-dix)/son a \3/g;
    s/\b(montlucon|montluçon|montre le volume|montre le son|monter le volume|monter le son)\b/monte le son/g;
    s/\bmonter[[:space:]]+(le[[:space:]]+)?(volume|son)\b/monte le son/g;
    s/\bbaisser[[:space:]]+(le[[:space:]]+)?(volume|son)\b/baisse le son/g
')

# Conversion des nombres français écrits par Vosk en chiffres
TXT=$(python3 -c '
import sys, re
t = sys.argv.__getitem__(1)
diz = {"vingt": 20, "trente": 30, "quarante": 40, "cinquante": 50, "soixante": 60, "soixante dix": 70, "soixante-dix": 70, "quatre vingt": 80, "quatre-vingt": 80, "quatre vingts": 80, "quatre-vingts": 80, "quatre vingt dix": 90, "quatre-vingt-dix": 90}
uni = {"zero": 0, "un": 1, "une": 1, "deux": 2, "trois": 3, "quatre": 4, "cinq": 5, "six": 6, "sept": 7, "huit": 8, "neuf": 9, "dix": 10, "onze": 11, "douze": 12, "treize": 13, "quatorze": 14, "quinze": 15, "seize": 16, "dix sept": 17, "dix huit": 18, "dix neuf": 19, "cent": 100}

for d_mot, d_val in sorted(diz.items(), key=lambda x: -len(x)):
    for u_mot, u_val in sorted(uni.items(), key=lambda x: -len(x)):
        if 1 <= u_val <= 9:
            t = re.sub(r"\b" + d_mot + r"[- ]+(?:et[- ]+)?" + u_mot + r"\b", str(d_val + u_val), t)
    t = re.sub(r"\b" + d_mot + r"\b", str(d_val), t)

for u_mot, u_val in sorted(uni.items(), key=lambda x: -len(x)):
    t = re.sub(r"\b" + u_mot + r"\b", str(u_val), t)
print(t)
' "$TXT")

# Corrections phonétiques courantes de Vosk FR
TXT=$(echo "$TXT" | sed -E "s/^son ([0-9]+)$/son a \1/" | sed -E '
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
    s/\b(web ia|web il a|web ya)\b/webia/g;
    s/\b(lire web|lis web|lire ouais)\b/lireweb/g;
    s/\b(souvenir|souvenire)\b/souvenirs/g;
    s/\b(arzens autrichien|arrete de reflechir)\b/annule/g;
    s/\b(aide moi|aides)\b/aide/g;
    s/\b(heures|peur|leurs)\b/heure/g;
    s/\b(solide|securiser|securisee|securises|protege|proteger|chiffre|chiffrer)\b/securise/g;
    s/.*(donne|dit|dis).*(heure|leur).*/heure/g;
    s/.*(donne|dit|dis).*(heure|leur).*/heure/g;
    s/\b(fenetre|fenêtres)\b/fenetres/g;
    s/\b(webcam|web cam)\b/cam/g
')
echo "$TXT" | sed -E "s/^son ([0-9]+)$/son a \1/"
