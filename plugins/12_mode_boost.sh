#!/usr/bin/env bash
# MENU_NAME: ⚡ Activer Mode Boost (Auto)
# MENU_DESC: Puissance à la demande (descente auto à 76°C, remontée à 63°C)
echo "auto" > /tmp/tiffany_cpu_mode
if ! pgrep -f "thermal_watchdog.sh" >/dev/null; then
    ~/tiffany/thermal_watchdog.sh >/dev/null 2>&1 &
fi
echo "ondemand" | sudo -n tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1
zenity --info --title="⚡ Boost Auto-Régulé" --text="🚀 Mode Boost intelligent activé !\n\n• Puissance à la demande (ondemand)\n• Descente auto en Froid dès 76°C\n• Remontée auto en Boost dès 63°C" --timeout=3 2>/dev/null
