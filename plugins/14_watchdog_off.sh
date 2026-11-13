#!/usr/bin/env bash
# MENU_NAME: ⚠️ Watchdog OFF
# MENU_DESC: Mettre en pause la sentinelle thermique
systemctl --user stop tiffany-watchdog.service >/dev/null 2>&1
pkill -f "thermal_watchdog.sh" >/dev/null 2>&1
notify-send -u low -t 3000 -i "weather-snow" "⚠️ Watchdog OFF" "Sentinelle thermique mise en pause."
