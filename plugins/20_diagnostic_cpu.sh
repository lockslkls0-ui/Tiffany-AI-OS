#!/bin/bash
# MENU_NAME: 🧠 Diagnostic CPU
# MENU_DESC: Température et processus en temps réel
gnome-terminal --title="📊 Fluctuations CPU" -- bash -c "while true; do clear; ~/tiffany/tiffany_utilitaire.sh 'etat_cpu'; sleep 2; done"
