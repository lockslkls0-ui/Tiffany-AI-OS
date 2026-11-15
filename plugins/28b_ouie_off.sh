#!/usr/bin/env bash
# MENU_NAME: 🔇 Couper l'Ouïe (OFF)
# MENU_DESC: Arrêter totalement l écoute vocale et Python (0% CPU)
touch "$HOME/.config/tiffany/oreille_off"
pkill -9 -f "03_moteur_ecoute|tiffany_ear_daemon|tiffany_ear_worker|arecord" 2>/dev/null || true
notify-send -u normal "🔇 Ouïe Vocale COUPÉE" "Micro et Python arrêtés jusqu au prochain clic ON."
