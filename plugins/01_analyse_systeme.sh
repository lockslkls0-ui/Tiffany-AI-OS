#!/usr/bin/env bash
# MENU_NAME: 🔍 Analyse Matérielle (Disque/Logs)
# MENU_DESC: Vérifier la santé du disque dur et les erreurs système
if [ -f "$HOME/analyse_systeme.sh" ]; then
    gnome-terminal --title="🔍 Analyse Matérielle" -- bash -c "bash '$HOME/analyse_systeme.sh'; read"
else
    bash "$HOME/tiffany/actions_terminal/02_analyse.sh"
fi
