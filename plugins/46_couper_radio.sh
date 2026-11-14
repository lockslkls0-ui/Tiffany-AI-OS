#!/bin/bash
# MENU_NAME: 🤫 Couper la Radio / Musique
# MENU_DESC: Arrêt instantané du lecteur Rhythmbox et nettoyage de la file
rhythmbox-client --stop >/dev/null 2>&1
rhythmbox-client --clear-queue >/dev/null 2>&1
