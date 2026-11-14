#!/usr/bin/env bash
# MENU_NAME: 🔍 Analyse Matérielle Éclair
# MENU_DESC: Bilan complet en français en 0,1s (CPU, Temp, RAM, Disque, Batterie)
INFO=$(bash "$HOME/tiffany/actions_terminal/02_analyse.sh" | sed -r 's/\x1B\[[0-9;]*[mK]//g')
zenity --info --title="🔍 Bilan Matériel Éclair" --text="$INFO" --width=540 2>/dev/null
