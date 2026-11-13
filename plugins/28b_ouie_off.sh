#!/usr/bin/env bash
# MENU_NAME: 🔇 Oreille Continue OFF
# MENU_DESC: Couper l'écoute vocale permanente en arrière-plan
pkill -f "tiffany_ear_daemon.sh" >/dev/null 2>&1
pkill -f "arecord -f S16_LE -r 16000" >/dev/null 2>&1
notify-send -u low -t 3000 -i "audio-input-microphone" "🔇 Oreille Coupée" "Écoute vocale permanente désactivée." >/dev/null 2>&1
