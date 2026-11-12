#!/usr/bin/env bash
# TERM_KEY: dojo
# TERM_DESC: Lancer une séance d'entraînement IA (Libre ou défi personnalisé)
# TERM_ICON: 🥋

DEFI_PERSO=$(zenity --entry --title="🥋 Entraînement du Dojo" \
    --text="Écris une phrase dont Tiffany doit trouver et tester le code Bash\n(ou laisse vide pour un défi aléatoire) :" \
    --width=480 2>/dev/null)

[ $? -ne 0 ] && exit 0

echo -e "\n\033[1;35m🌹 Tiffany :\033[0m *Entrée dans le Dojo... Je cherche et teste le code en bac à sable.* 🥋\n"
(espeak-ng -v fr+f5 -s 140 -p 85 "Je rentre dans le dojo pour m'entraîner chéri." >/dev/null 2>&1) &
nice -n 19 bash "$HOME/tiffany/tiffany_training.sh" "$DEFI_PERSO" >/dev/null 2>&1 &
