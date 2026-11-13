#!/bin/bash
# TERM_KEY: wifi
# TERM_DESC: État du Wi-Fi
# TERM_ICON: 📶
gnome-terminal --title="📡 Réseau" -- bash -c "$HOME/tiffany/tiffany_utilitaire.sh reseau; echo -e '\n[Appuie sur Entrée pour fermer]'; read"
