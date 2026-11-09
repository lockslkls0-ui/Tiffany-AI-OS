#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_watchdog.sh (Version 12.2 - GESTION THERMIQUE SÉCURISÉE)
# 🛡️ RÔLE   : Vérifie la température toutes les 15 secondes SANS blocage sudo
# ==============================================================================

ROOT_DIR="$HOME/tiffany"
mkdir -p "$ROOT_DIR/logs"

while true; do
    TEMP=""
    
    # Lecture ultra-rapide et native via le noyau Linux (Zéro consommation CPU)
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        [ -n "$TEMP_RAW" ] && TEMP=$((TEMP_RAW / 1000))
    fi

    # Solution de secours si la zone ACPI n'est pas mappée à cet emplacement
    if [ -z "$TEMP" ]; then
        TEMP=$(sensors 2>/dev/null | grep -E '(Core 0|CPU|temp1)' | head -n 1 | grep -oE '[0-9]+' | head -n 1)
    fi
    
    # Seuil d'alerte à 78°C
    if [ -n "$TEMP" ] && [ "$TEMP" -gt 78 ]; then
        echo "[$(date '+%T')] 🔥 ALERTE THERMIQUE : ${TEMP}°C. Limitation Powersave." >> "$ROOT_DIR/logs/thermique.log"
        
        # Utilisation de la redirection standard pour éviter le piège du sudo interactif bloquant
        if [ "$EUID" -eq 0 ]; then
            echo "powersave" > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null
        else
            echo "powersave" | sudo -n tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
        fi
    fi
    sleep 15
done
