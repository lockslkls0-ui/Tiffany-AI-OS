#!/bin/bash
# MENU_NAME: 🧠 Check-up RAM (Top)
# MENU_DESC: Applications qui saturent la mémoire
gnome-terminal --title="🧠 Fluctuations RAM" -- bash -c "while true; do clear; ~/tiffany/tiffany_utilitaire.sh 'processus_ram'; sleep 2; done"
