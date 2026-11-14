#!/usr/bin/env bash
# MENU_NAME: 🧠 Voir sa Mémoire & Logs
# MENU_DESC: Afficher tout ce que Tiffany retient en direct (Souvenirs, Fil, SMART)
TEXTE=$(python3 "$HOME/tiffany/lire_memoire_totale.py" | sed 's/ | /\n\n• /g; s/^/• /')
zenity --info --title="🧠 Mémoire Totale de Tiffany (En Direct)" --text="$TEXTE" --width=580 --height=420 2>/dev/null
