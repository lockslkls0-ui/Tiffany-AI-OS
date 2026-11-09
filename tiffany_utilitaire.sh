#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_utilitaire.sh (Version 11.0 - PANOPLIE SECURISEE)
# 🛡️ RÔLE   : Gestion matérielle, thermique, audio et système native
# ==============================================================================

action="$1"
option="$2"
ROOT_DIR="$HOME/tiffany"

case "$action" in
    "lock")
        echo -e "\n🔒 *Verrouillage de la session...*"
        cinnamon-screensaver-command -l >/dev/null 2>&1 || xdg-screensaver lock >/dev/null 2>&1
        ;;
        
    "wifi")
        if [ "$option" = "off" ]; then
            echo -e "\n📡 *Désactivation du Wi-Fi...*"
            nmcli radio wifi off >/dev/null 2>&1
        else
            echo -e "\n📡 *Activation du Wi-Fi...*"
            nmcli radio wifi on >/dev/null 2>&1
        fi
        ;;
        
    "filtre")
        if [ "$option" = "nuit" ]; then
            echo -e "\n🌙 *Activation du mode nuit (Filtre chaud)...*"
            if ! command -v redshift &>/dev/null; then sudo apt update && sudo apt install redshift -y >/dev/null 2>&1; fi
            redshift -O 3700k >/dev/null 2>&1 &
        else
            echo -e "\n☀️ *Retour à la luminosité normale...*"
            killall redshift >/dev/null 2>&1
            redshift -x >/dev/null 2>&1
        fi
        ;;
        
    "corbeille")
        echo -e "\n🧼 *Vidage de la corbeille...*"
        rm -rf "$HOME/.local/share/Trash/files"/* >/dev/null 2>&1
        rm -rf "$HOME/.local/share/Trash/info"/* >/dev/null 2>&1
        echo -e "🌹 Tiffany : ✅ Corbeille entièrement vidée, mon ange."
        ;;

    "uptime")
        echo -e "\n⏱️ *Temps d'activité du système :*"
        echo -n "👉 "
        uptime -p 2>/dev/null || uptime
        ;;

    "calendrier")
        echo -e "\n📅 *Calendrier du mois en cours :*\n"
        cal -m
        ;;

    "nettoie_ram")
        echo -e "\n🌹 Tiffany : *Purge et libération de la mémoire vive cache...*"
        sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1
        echo -e "🌹 Tiffany : ✅ RAM nettoyée et optimisée, chéri.\n"
        ;;

    "refroidissement")
        if [ "$option" = "froid" ]; then
            echo -e "\n❄️ *Bouclier thermique activé d'urgence. Limitation du processeur...*"
            echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
        else
            echo -e "\n⚡ *Restauration de la puissance CPU...*"
            echo "ondemand" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1 || \
            echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
        fi
        ;;

    "etat_cpu")
        echo -e "\n\033[1;34m📊 [ DIAGNOSTIC MATÉRIEL DU PROCESSEUR ] \033[0m"
        # Extraction de secours robuste si sensors n'est pas au format exact
        TEMP_RAW=$(sensors 2>/dev/null | grep -E '(Core 0|CPU|temp1)' | head -n 1 | grep -oE '\+[0-9]+' | head -n 1)
        if [ -z "$TEMP_RAW" ] && [ -f /sys/class/thermal/thermal_zone0/temp ]; then
            TEMP_RAW="+$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))"
        fi
        FREQ_RAW=$(grep "cpu MHz" /proc/cpuinfo | head -n 1 | awk '{print int($4)" MHz"}')
        echo -e "-------------------------------------------------------------------"
        echo -e "🌡️  Température actuelle : \033[1;31m${TEMP_RAW}°C\033[0m"
        echo -e "⚡ Cadence CPU active   : \033[1;33m${FREQ_RAW}\033[0m"
        echo -e "-------------------------------------------------------------------"
        echo -e "\033[1;35m🔥 Les 3 applications qui surchauffent ton système :\033[0m"
        ps -eo pid,%cpu,comm --sort=-%cpu | grep -vE "(grep|ps|tiffany)" | head -n 4 | awk 'NR>1 {printf "  -> PID: %-6s | CPU: %-4s%% | %s\n", $1, $2, $3}'
        echo -e "-------------------------------------------------------------------"
        ;;

    "freeze_ia")
        if [ "$option" = "stop" ]; then
            echo -e "\n🧊 🌹 Tiffany : *Je gèle ma matrice locale Ollama pour refroidir le Toshiba...*"
            sudo killall -STOP ollama 2>/dev/null
            sudo killall -STOP ollama_llama_server 2>/dev/null
        else
            echo -e "\n🔥 🌹 Tiffany : *Réactivation de mes moteurs locaux...*"
            sudo killall -CONT ollama 2>/dev/null
            sudo killall -CONT ollama_llama_server 2>/dev/null
        fi
        ;;

    "reseau")
        echo -e "\n📡 *État de ta connexion réseau :*"
        IP_LOC=$(hostname -I | awk '{print $1}')
        WIFI_NAME=$(nmcli -t -f active,ssid dev wifi | grep '^oui' | cut -d: -f2)
        [ -z "$WIFI_NAME" ] && WIFI_NAME="Déconnecté / Filaire"
        echo -e "👉 Point d'accès : \033[1;32m$WIFI_NAME\033[0m"
        echo -e "👉 IP locale     : \033[1;34m$IP_LOC\033[0m"
        ;;

    "audio")
        if [ "$option" = "toggle" ]; then
            echo -e "\n🔊 *Bascule du mode muet...*"
            amixer set Master toggle >/dev/null 2>&1
        else
            echo -e "\n🔊 *Réglage du volume général à ${option}%...*"
            amixer set Master "${option}%" >/dev/null 2>&1
        fi
        ;;

    "autonomie")
        echo -e "\n🔋 *Estimation de la réserve d'énergie :*"
        acpi -b 2>/dev/null || upower -i $(upower -e | grep 'battery') | grep -E '(state|to full|to empty|percentage)'
        ;;

    "nettoie_systeme")
        echo -e "\n🧼 *Nettoyage complet des résidus système APT...*"
        sudo apt-get autoremove -y >/dev/null 2>&1
        sudo apt-get autoclean -y >/dev/null 2>&1
        echo -e "🌹 Tiffany : ✅ Débris système purgés avec succès, chéri."
        ;;

    "luminosite")
        echo -e "\n🖥️ *Ajustement du panneau de rétroéclairage à ${option}%...*"
        if command -v brightnessctl &>/dev/null; then
            sudo brightnessctl set "${option}%" >/dev/null 2>&1
        else
            xdotool key XF86MonBrightnessDown >/dev/null 2>&1 
        fi
        ;;

    "ecran_off")
        echo -e "\n🖥️ *Extinction immédiate de la dalle (Veille forcée)...*"
        sleep 0.5 && xset dpms force off
        ;;

    "processus_ram" | "processus_ram")
        echo -e "\n🧠 *Top 5 des consommations de Mémoire Vive (RAM) :*"
        echo -e "-------------------------------------------------------------------"
        ps -eo pid,%mem,comm --sort=-%mem | head -n 6 | awk 'NR>1 {printf "  -> PID: %-6s | RAM: %-4s%% | %s\n", $1, $2, $3}'
        echo -e "-------------------------------------------------------------------"
        ;;
esac
