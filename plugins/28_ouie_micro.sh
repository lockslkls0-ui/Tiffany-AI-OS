#!/usr/bin/env bash
# MENU_NAME: 👂 Oreille Continue ON (Mains-Libres)
# MENU_DESC: Écoute permanente du mot 'Tiffany' + commandes vocales instantanées
pkill -f "tiffany_ear_daemon.sh" >/dev/null 2>&1
nice -n 15 ~/tiffany/tiffany_ear_daemon.sh >/dev/null 2>&1 &
