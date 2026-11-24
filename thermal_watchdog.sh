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
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u low -t 3500 -i "$3" "$1" "$2" >/dev/null 2>&1
    fi
}

CURRENT_MODE=""
LAST_RAM_CLEAN=0

while true; do
    # --- BOUCLE 1 : PROTECTION THERMIQUE CPU ---
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print int($1/1000)}')
    [ -z "$TEMP" ] && TEMP=$(sensors 2>/dev/null | grep -E '(Core 0|CPU|temp1)' | head -n 1 | grep -oE '[0-9]+' | head -n 1)
    WANTED=$(cat "$STATE_FILE" 2>/dev/null || echo "auto")

    if [ "$WANTED" = "force_froid" ]; then
        if [ "$CURRENT_MODE" != "froid" ]; then
            set_gov "powersave"
            CURRENT_MODE="froid"
        fi
    else
        if [ -n "$TEMP" ] && [ "$TEMP" -ge 75 ]; then
            if [ "$CURRENT_MODE" != "froid" ]; then
                set_gov "powersave"
                CURRENT_MODE="froid"
                echo "[$(date '+%T')] ❄️ (${TEMP}°C) : Descente douce en Mode Froid." >> "$ROOT_DIR/logs/thermique.log"
                alerter_douce "❄️ Bouclier Thermique (${TEMP}°C)" "Mode Froid activé automatiquement pour rafraîchir le CPU." "weather-snow"
            fi
        elif [ -n "$TEMP" ] && [ "$TEMP" -le 62 ]; then
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

    # --- BOUCLE 2 : BOUCLIER ANTI-SATURATION RAM & LIBÉRATION MODÈLES IA ---
    RAM_PCT=$(free -m | awk '/Mem:/ {print int($3/$2*100)}')
    NOW=$(date +%s)
    if [ -n "$RAM_PCT" ] && [ "$RAM_PCT" -ge 80 ] && [ $((NOW - LAST_RAM_CLEAN)) -ge 60 ]; then
        LAST_RAM_CLEAN=$NOW
        sync
        echo 1 | sudo -n tee /proc/sys/vm/drop_caches >/dev/null 2>&1 || true
        curl -s -X POST http://localhost:11434/api/generate -d '{"model":"tiffany-pro","keep_alive":0}' >/dev/null 2>&1 || true
        curl -s -X POST http://localhost:11434/api/generate -d '{"model":"qwen2.5:1.5b","keep_alive":0}' >/dev/null 2>&1 || true
        curl -s -X POST http://localhost:11434/api/generate -d '{"model":"qwen2.5-coder:1.5b","keep_alive":0}' >/dev/null 2>&1 || true
        echo "[$(date '+%T')] 🧠 (${RAM_PCT}% RAM) : Bouclier mémoire activé (caches & IA lourdes libérés)." >> "$ROOT_DIR/logs/thermique.log"
        alerter_douce "🧠 Bouclier Mémoire (${RAM_PCT}%)" "RAM libérée automatiquement pour garder ton PC fluide." "drive-harddisk"
    fi

    # --- BOUCLE 3 : CHASSE AUX PROCESSUS FOUS ZENITY / PIPER BLOQUÉS ---
    for pid in $(pgrep -x zenity); do
        ETIME=$(ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' ')
        if [ -n "$ETIME" ] && [ "$ETIME" -gt 1800 ]; then
            kill -9 "$pid" 2>/dev/null || true
        fi
    done

    # --- BOUCLE 4 : COUPE-CIRCUIT ANTI-SURCHAUFFE LLAMA-SERVER ---
    if [ -n "$TEMP" ] && [ "$TEMP" -ge 88 ]; then
        killall -9 llama-server >/dev/null 2>&1 || true
        echo "[$(date '+%T')] 🔥 (${TEMP}°C) : Coupe-circuit llama-server déclenché !" >> "$ROOT_DIR/logs/thermique.log"
    fi

    sleep 4
done
