#!/usr/bin/env bash
# MENU_NAME: 🛡️ Watchdog ON (Permanent)
# MENU_DESC: Activer la sentinelle thermique auto-réparatrice au démarrage
systemctl --user enable --now tiffany-watchdog.service >/dev/null 2>&1 || ~/tiffany/thermal_watchdog.sh >/dev/null 2>&1 &
notify-send -u low -t 3000 -i "weather-clear" "🛡️ Watchdog ON" "Sentinelle thermique permanente activée !"
