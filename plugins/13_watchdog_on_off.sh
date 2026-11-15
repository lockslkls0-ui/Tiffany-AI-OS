#!/usr/bin/env bash
# MENU_NAME: 🛡️ Watchdog Thermique (ON / OFF)
# MENU_DESC: Basculer la sentinelle thermique permanente ON ou OFF
if systemctl --user is-active --quiet tiffany-watchdog.service 2>/dev/null || pgrep -f "thermal_watchdog.sh" >/dev/null 2>&1; then
    systemctl --user stop tiffany-watchdog.service >/dev/null 2>&1 || true
    pkill -f "thermal_watchdog.sh" >/dev/null 2>&1 || true
    notify-send -u low -t 3000 -i "weather-snow" "⚠️ Watchdog OFF" "Sentinelle thermique mise en pause."
else
    systemctl --user enable --now tiffany-watchdog.service >/dev/null 2>&1 || ~/tiffany/thermal_watchdog.sh >/dev/null 2>&1 &
    notify-send -u low -t 3000 -i "weather-clear" "🛡️ Watchdog ON" "Sentinelle thermique permanente activée !"
fi
