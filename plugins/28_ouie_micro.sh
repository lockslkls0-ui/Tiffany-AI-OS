#!/usr/bin/env bash
# MENU_NAME: 👂 Oreille Continue ON (Permanente)
# MENU_DESC: Écoute automatique au démarrage + détection de fin de phrase
pkill -f "tiffany_ear_daemon.sh" >/dev/null 2>&1
systemctl --user enable --now tiffany-ear.service >/dev/null 2>&1
