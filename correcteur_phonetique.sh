#!/usr/bin/env bash
TXT="$1"
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
