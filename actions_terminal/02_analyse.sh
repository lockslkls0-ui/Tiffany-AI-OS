#!/usr/bin/env bash
# TERM_KEY: analyse
# TERM_DESC: Bilan matériel en temps réel parlé et écrit en français
# TERM_ICON: 🔍

MODELE=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || echo "Ordinateur Linux")
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print int($1/1000)}')
[ -z "$TEMP" ] && TEMP=$(sensors 2>/dev/null | grep -E '(Core 0|CPU|temp1)' | head -n 1 | grep -oE '[0-9]+' | head -n 1)
FREQ=$(awk -F': ' '/cpu MHz/ {print int($2); exit}' /proc/cpuinfo)
GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
[[ "$GOV" == "powersave" ]] && MODE_FR="Mode Froid (économie)" || MODE_FR="Mode Fluide (ondemand)"

RAM_TOT=$(free -h | awk '/Mem:/ {print $2}' | sed 's/Gi/ Go/; s/Mi/ Mo/')
RAM_USE=$(free -h | awk '/Mem:/ {print $3}' | sed 's/Gi/ Go/; s/Mi/ Mo/')
RAM_DISP=$(free -h | awk '/Mem:/ {print $7}' | sed 's/Gi/ Go/; s/Mi/ Mo/')
ZRAM_STAT=$(zramctl --noheadings --output DATA,COMPR 2>/dev/null | awk '{print $1 " compressés en " $2}')

TOP_APP=$(ps -eo comm,%cpu --sort=-%cpu | grep -vE "^(COMMAND|ps|bash|awk)" | head -n 1 | awk '{print $1 " (" $2 "%)"}')
DISK_LIBRE=$(df -h / | awk 'NR==2 {print $4 " libres sur " $2}' | sed 's/G/ Go/g')
BAT_CAP=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo "100")
BAT_STAT=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1)
[[ "$BAT_STAT" == "Charging" || "$BAT_STAT" == "Full" ]] && SECTEUR="branché sur secteur" || SECTEUR="sur batterie"

WIFI_SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep -E '^(oui|yes)' | cut -d: -f2)
[ -z "$WIFI_SSID" ] && WIFI_SSID="Non connecté"

echo -e "\n\033[1;36m🔍 [ANALYSE TEMPS RÉEL EN FRANÇAIS — DONNÉES DIRECTES] :\033[0m"
echo -e "-------------------------------------------------------------------"
echo -e " 💻 Ordinateur   : \033[1;32m$MODELE\033[0m"
echo -e " 🌡️ Processeur   : \033[1;33m${TEMP}°C\033[0m à \033[1;36m${FREQ} MHz\033[0m ($MODE_FR)"
echo -e " 🔥 Plus gourmand: $TOP_APP"
echo -e " 🧠 Mémoire RAM  : \033[1;32m$RAM_DISP disponibles\033[0m ($RAM_USE utilisés sur $RAM_TOT)"
echo -e " 🚀 Turbo ZRAM   : ${ZRAM_STAT:-Actif}"
echo -e " 💾 Disque dur   : $DISK_LIBRE"
echo -e " 🔋 Batterie     : \033[1;32m${BAT_CAP}%\033[0m ($SECTEUR)"
echo -e " 📶 Réseau Wi-Fi : $WIFI_SSID"
echo -e "-------------------------------------------------------------------\n"

PHRASE_FR="Analyse en temps réel de ton $MODELE : le processeur est à ${TEMP} degrés à ${FREQ} mégahertz en ${MODE_FR}. Tu as ${RAM_DISP} de mémoire disponible, ${DISK_LIBRE} sur ton disque dur, et ta batterie est à ${BAT_CAP} pour cent, ${SECTEUR}."
pkill -x espeak-ng >/dev/null 2>&1
(espeak-ng -v fr+f5 -s 145 -p 85 "$PHRASE_FR" >/dev/null 2>&1) &
