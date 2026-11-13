#!/usr/bin/env bash
ROOT_DIR="$HOME/tiffany"
mkdir -p "$ROOT_DIR/logs"
STATE_FILE="/tmp/tiffany_cpu_mode"
[ -f "$STATE_FILE" ] || echo "auto" > "$STATE_FILE"

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

set_gov() {
    echo "$1" | sudo -n tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1
}

alerter_douce() {
    local TITRE="$1"
    local MSG="$2"
    local ICONE="$3"
    # Bulle native Linux Mint en haut à droite au-dessus de tout (silencieuse et non-bloquante)
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u low -t 3500 -i "$ICONE" "$TITRE" "$MSG" >/dev/null 2>&1
    fi
}

CURRENT_MODE=""

while true; do
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print int($1/1000)}')
    [ -z "$TEMP" ] && TEMP=$(sensors 2>/dev/null | grep -E '(Core 0|CPU|temp1)' | head -n 1 | grep -oE '[0-9]+' | head -n 1)

    WANTED=$(cat "$STATE_FILE" 2>/dev/null || echo "auto")

    if [ "$WANTED" = "force_froid" ]; then
        if [ "$CURRENT_MODE" != "froid" ]; then
            set_gov "powersave"
            CURRENT_MODE="froid"
        fi
    else
        if [ -n "$TEMP" ] && [ "$TEMP" -ge 76 ]; then
            if [ "$CURRENT_MODE" != "froid" ]; then
                set_gov "powersave"
                CURRENT_MODE="froid"
                echo "[$(date '+%T')] ❄️ (${TEMP}°C) : Descente douce en Mode Froid." >> "$ROOT_DIR/logs/thermique.log"
                alerter_douce "❄️ Bouclier Thermique (${TEMP}°C)" "Mode Froid activé en douceur pour rafraîchir le CPU." "weather-snow"
            fi
        elif [ -n "$TEMP" ] && [ "$TEMP" -le 63 ]; then
            if [ "$CURRENT_MODE" != "fluide" ]; then
                set_gov "ondemand"
                CURRENT_MODE="fluide"
                echo "[$(date '+%T')] ⚡ (${TEMP}°C) : Remontée douce en Mode Boost." >> "$ROOT_DIR/logs/thermique.log"
                alerter_douce "⚡ Boost Auto (${TEMP}°C)" "Processeur frais : pleine fluidité réactivée." "weather-clear"
            fi
        elif [ -z "$CURRENT_MODE" ]; then
            set_gov "ondemand"
            CURRENT_MODE="fluide"
        fi
    fi
    sleep 5
done
