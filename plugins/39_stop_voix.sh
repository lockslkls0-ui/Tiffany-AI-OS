#!/usr/bin/env bash
# MENU_NAME: 🤐 Stopper la Lecture Vocale
# MENU_DESC: Couper immédiatement la voix de Tiffany si elle lit un long texte
pkill -x espeak-ng >/dev/null 2>&1
notify-send -u low -t 2500 -i "audio-volume-muted" "🤐 Voix coupée" "Lecture vocale interrompue." >/dev/null 2>&1
