#!/usr/bin/env bash
# TERM_KEY: lireweb
# TERM_DESC: Lire a haute voix le dernier dossier Web-IA enregistre
# TERM_ICON: 📖

DOSSIER="$HOME/Bureau/WebIA_Dossiers"
[ ! -d "$DOSSIER" ] && DOSSIER="$HOME/Desktop/WebIA_Dossiers"
DERNIER=$(ls -t "$DOSSIER"/*.md 2>/dev/null | head -n 1)

if [ -z "$DERNIER" ] || [ ! -f "$DERNIER" ]; then
    echo -e "\n\033[1;33m📖 Aucun dossier Web-IA enregistré sur ton Bureau pour le moment.\033[0m\n"
    (espeak-ng -v fr+f5 -s 140 -p 85 "Je n'ai trouvé aucun dossier web enregistré sur ton bureau, mon ange." >/dev/null 2>&1) &
    exit 0
fi

TEXTE_PROPRE=$(grep -vE '^(---|# 📁|\*\*Date)' "$DERNIER" | sed 's/[#*`>-]//g' | tr '\n' ' ' | xargs | head -c 1500)
echo -e "\n\033[1;35m📖 Lecture de : $(basename "$DERNIER")\033[0m\n$TEXTE_PROPRE\n"
pkill -x espeak-ng >/dev/null 2>&1
(espeak-ng -v fr+f5 -s 140 -p 85 "$TEXTE_PROPRE" >/dev/null 2>&1) &
