#!/usr/bin/env bash
# MENU_NAME: 👂 Activer l'Ouïe (ON)
# MENU_DESC: Démarrer l écoute vocale continue en boucle
rm -f "$HOME/.config/tiffany/oreille_off"
nohup flock -n /tmp/tiffany_ear.lock bash "$HOME/tiffany/tiffany_ear_daemon.sh" >/dev/null 2>&1 &
notify-send -u normal "👂 Ouïe Vocale ACTIVÉE" "Écoute continue en boucle active !"
