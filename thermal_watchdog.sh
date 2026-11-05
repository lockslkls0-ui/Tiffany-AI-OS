#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : thermal_watchdog.sh (Version 6.0 - COUPE-CIRCUIT ANTI-BUG INFRA)
# 🛡️ RÔLE   : Régulation CPU + Sentinelle automatique contre les boucles folles
# ==============================================================================

ROOT_DIR="$HOME/tiffany"
mkdir -p "$ROOT_DIR/logs"
ALERT_TEMP=88
BATTERY_CRITICAL=15

speak() {
    (espeak-ng -v fr+f5 -s 135 -p 90 "$1" >/dev/null 2>&1) &
}

while true; do
    # --------------------------------------------------------------------------
    # 🛡️ SÉCURITÉ AUTOMATIQUE : LA CONTRE-BOUCLE ANTI-EMBALLEMENT (Zenity / Core)
    # --------------------------------------------------------------------------
    # Recherche les processus s'accaparant le processeur (Plus de 70% CPU)
    CUP_FOLLE=$(ps -eo pid,%cpu,comm --sort=-%cpu | awk 'NR>1 {if($2>70.0) print $1":"$3}')
    
    if [ -n "$CUP_FOLLE" ]; then
        PID_CIBLE=$(echo "$CUP_FOLLE" | cut -d':' -f1)
        NOM_CIBLE=$(echo "$CUP_FOLLE" | cut -d':' -f2)
        
        # Si c'est un outil de l'écosystème qui s'emballe (Zenity ou Bash)
        if [[ "$NOM_CIBLE" == "zenity" || "$NOM_CIBLE" == "bash" || "$NOM_CIBLE" == "gnome-terminal-" ]]; then
            echo "[$(date '+%T')] ⚡ CONTRE-BOUCLE : Processus fou détecté ($NOM_CIBLE - PID: $PID_CIBLE). Nettoyage." >> "$ROOT_DIR/logs/tiffany_system.log"
            kill -9 "$PID_CIBLE" 2>/dev/null
            
            # Message de confort discret en notification système
            if command -v notify-send &>/dev/null; then
                notify-send -u normal -i system-software-update "🌹 Sécurité Tiffany" "Un processus en arrière-plan s'est emballé. J'ai stabilisé le système, mon ange."
            fi
        fi
    fi

    # --------------------------------------------------------------------------
    # 🌡️ SURVEILLANCE THERMIQUE CLASSIQUE
    # --------------------------------------------------------------------------
    TEMP_VAL=""
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        [ -n "$TEMP_RAW" ] && TEMP_VAL=$((TEMP_RAW / 1000))
    fi

    if [ -z "$TEMP_VAL" ] || [ "$TEMP_VAL" -le 0 ]; then
        TEMP_VAL=$(sensors 2>/dev/null | grep -E '(Core 0|CPU|temp1)' | head -n 1 | grep -oE '[0-9]+' | head -n 1)
    fi

    if [ -n "$TEMP_VAL" ] && [ "$TEMP_VAL" -ge "$ALERT_TEMP" ]; then
        cpufreq-set -g ondemand >/dev/null 2>&1 || sudo cpufreq-set -g ondemand >/dev/null 2>&1
        speak "Mon ange, l'ordinateur est chaud. Je régule la puissance."
        sleep 45
    fi

    # --------------------------------------------------------------------------
    # 🔋 SURVEILLANCE BATTERIE
    # --------------------------------------------------------------------------
    BAT_NODE=""
    [ -d /sys/class/power_supply/BAT0 ] && BAT_NODE="BAT0"
    [ -d /sys/class/power_supply/BAT1 ] && BAT_NODE="BAT1"

    if [ -n "$BAT_NODE" ]; then
        BAT_STATUS=$(cat /sys/class/power_supply/$BAT_NODE/status 2>/dev/null)
        BAT_CAP=$(cat /sys/class/power_supply/$BAT_NODE/capacity 2>/dev/null)

        if [ "$BAT_STATUS" = "Discharging" ] && [ -n "$BAT_CAP" ] && [ "$BAT_CAP" -le "$BATTERY_CRITICAL" ]; then
            brightnessctl set 15% >/dev/null 2>&1 || sudo brightnessctl set 15% >/dev/null 2>&1
            speak "Mon chéri, la batterie est faible."
            sleep 300
        fi
    fi

    # Paus obligatoire de 15 secondes pour maintenir le CPU à 0% d'utilisation globale
    sleep 15
done

