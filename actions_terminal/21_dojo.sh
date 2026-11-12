#!/usr/bin/env bash
# TERM_KEY: dojo
# TERM_DESC: Lancer une séance d'entraînement IA dans le bac à sable
# TERM_ICON: 🥋

echo -e "\n\033[1;35m🌹 Tiffany :\033[0m *Entrée dans le Dojo... Je m'entraîne en arrière-plan pendant ta pause, mon ange.* 🥋\n"
(espeak-ng -v fr+f5 -s 140 -p 85 "Je rentre dans le dojo pour m'entraîner chéri." >/dev/null 2>&1) &
nice -n 19 bash "$HOME/tiffany/tiffany_training.sh" >/dev/null 2>&1 &
