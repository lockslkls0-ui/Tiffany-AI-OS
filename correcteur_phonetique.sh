#!/usr/bin/env bash
TXT="$1"

# Conversion des nombres français écrits par Vosk en chiffres
TXT=$(python3 -c '
import sys, re
t = sys.argv[1]
diz = {"vingt": 20, "trente": 30, "quarante": 40, "cinquante": 50, "soixante": 60, "soixante dix": 70, "soixante-dix": 70, "quatre vingt": 80, "quatre-vingt": 80, "quatre vingts": 80, "quatre-vingts": 80, "quatre vingt dix": 90, "quatre-vingt-dix": 90}
uni = {"zero": 0, "un": 1, "une": 1, "deux": 2, "trois": 3, "quatre": 4, "cinq": 5, "six": 6, "sept": 7, "huit": 8, "neuf": 9, "dix": 10, "onze": 11, "douze": 12, "treize": 13, "quatorze": 14, "quinze": 15, "seize": 16, "dix sept": 17, "dix huit": 18, "dix neuf": 19, "cent": 100}

for d_mot, d_val in sorted(diz.items(), key=lambda x: -len(x[0])):
    for u_mot, u_val in sorted(uni.items(), key=lambda x: -len(x[0])):
        if 1 <= u_val <= 9:
            t = re.sub(r"\b" + d_mot + r"[- ]+(?:et[- ]+)?" + u_mot + r"\b", str(d_val + u_val), t)
    t = re.sub(r"\b" + d_mot + r"\b", str(d_val), t)

for u_mot, u_val in sorted(uni.items(), key=lambda x: -len(x[0])):
    t = re.sub(r"\b" + u_mot + r"\b", str(u_val), t)
print(t)
' "$TXT")

# Corrections phonétiques courantes de Vosk FR
TXT=$(echo "$TXT" | sed -E '
    s/\b(boss|boste|boust|booster|bouste)\b/boost/g;
    s/\b(frais|froide|frois)\b/froid/g;
    s/\b(rame|rames)\b/ram/g;
    s/\b(rythme|rythmes|ritme)\b/rhythmbox/g;
    s/\b(nexte|nekst|suivante)\b/next/g;
    s/\b(pose|pauses)\b/pause/g;
    s/\b(muette|muets)\b/muet/g;
    s/\b(menue|menus)\b/menu/g;
    s/\b(noix|noyer|noyaux)\b/noyau/g;
    s/\b(aide moi|aides)\b/aide/g;
    s/\b(test ia|teste ia)\b/testia/g;
    s/\b(web ia)\b/webia/g;
    s/\b(lire web|lis web)\b/lireweb/g;
    s/\b(fenetre|fenêtres)\b/fenetres/g;
    s/\b(webcam|web cam)\b/cam/g
')
echo "$TXT"
