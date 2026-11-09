#!/bin/bash
while true; do
    sleep 5
    TEMP=$(sensors 2>/dev/null | grep -A 0 "Core 0" | awk '{print $3}' | tr -d '+' | cut -d'.' -f1)
    [ -z "$TEMP" ] && TEMP=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}')
    if [ -n "$TEMP" ] && [ "$TEMP" -gt 82 ]; then
        ~/tiffany/tiffany_utilitaire.sh "refroidissement" "froid"
        echo "🚨 Alerte thermique active (${TEMP}°C) : CPU bridé par précaution."
    fi
done
