#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_espace.sh (Version 10.9)
# 🛡️ RÔLE   : Radar d'espace disque - Trouve les 10 fichiers/dossiers les plus lourds
# ==============================================================================

ROOT_DIR="$HOME/tiffany"

echo -e "🔎 🌹 Tiffany : *Sondage de ton disque en cours, mon ange...*"
(espeak-ng -v fr+f5 -s 135 -p 90 "Je cherche ce qui prend de la place chéri" >/dev/null 2>&1) &

echo -e "\n📊 [LES 10 ÉLÉMENTS LES PLUS LOURDS DANS TON DOSSIER PERSONNEL] :\n"
echo "------------------------------------------------------------------"

# Scan des dossiers et fichiers cachés inclus, tri par taille humaine (Go/Mo)
# Exclut les répertoires systèmes ou les montages virtuels s'il y en a
du -hs "$HOME"/* "$HOME"/.[!.]* 2>/dev/null | sort -rh | head -n 10 | awk '
BEGIN { print "  TAILLE\t| EMPLACEMENT" ; print "------------------------------------------------------------------" }
{ printf "  %-8s\t| %s\n", $1, $2 }'

echo "------------------------------------------------------------------"
(espeak-ng -v fr+f5 -s 135 -p 90 "Scan terminé" >/dev/null 2>&1) &

