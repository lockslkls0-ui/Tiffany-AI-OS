#!/usr/bin/env bash
# TERM_KEY: analyse
# TERM_DESC: Bilan matériel éclair en français (CPU, Temp, RAM, Disque, Batterie)
# TERM_ICON: 🔍

MODELE=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || echo "PC Linux")
CPU_NOM=$(grep -m1 "model name" /proc/cpuinfo | cut -d':' -f2 | sed 's/(R)//g; s/(TM)//g' | xargs)
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print int($1/1000)}')
GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
RAM_TOT=$(free -h | awk '/Mem:/ {print $2}')
RAM_DISP=$(free -h | awk '/Mem:/ {print $7}')
ZRAM_STAT=$(zramctl --noheadings --output DATA,COMPR 2>/dev/null | awk '{print $1 " compressés en " $2}')
DISK_LIBRE=$(df -h / | awk 'NR==2 {print $4 " libres sur " $2 " (" $5 " utilisés)"}')
BAT_CAP=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo "100")
BAT_STAT=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1)
[[ "$BAT_STAT" == "Charging" || "$BAT_STAT" == "Full" ]] && SECTEUR="branché sur secteur" || SECTEUR="sur batterie"
UPTIME_FR=$(uptime -p | sed 's/up //; s/days/jours/; s/day/jour/; s/hours/heures/; s/hour/heure/; s/minutes/minutes/')
ERR_CRIT=$(journalctl -p 3 -n 1 --no-pager -q 2>/dev/null | cut -d' ' -f5- | head -c 90)

echo -e "\n\033[1;36m🔍 [BILAN MATÉRIEL ÉCLAIR EN FRANÇAIS — 0,05s] :\033[0m"
echo -e "-------------------------------------------------------------------"
echo -e " 💻 Machine     : \033[1;32m$MODELE\033[0m ($CPU_NOM)"
echo -e " 🌡️ Thermique   : \033[1;33m${TEMP}°C\033[0m (Mode : $GOV)"
echo -e " 🧠 Mémoire RAM : \033[1;32m$RAM_DISP disponibles\033[0m sur $RAM_TOT (ZRAM : ${ZRAM_STAT:-Actif})"
echo -e " 💾 Stockage    : $DISK_LIBRE"
echo -e " 🔋 Énergie     : \033[1;32m${BAT_CAP}%\033[0m ($SECTEUR)"
echo -e " ⏱️ Activité    : Allumé depuis $UPTIME_FR"
echo -e " 🛡️ Dernier log : ${ERR_CRIT:-Aucune erreur critique récente}"
echo -e "-------------------------------------------------------------------\n"

RESUME_VOCAL="Bilan éclair de ton $MODELE : processeur à ${TEMP} degrés, ${RAM_DISP} de mémoire libre, disque avec ${DISK_LIBRE}, et batterie à ${BAT_CAP} pour cent, ${SECTEUR}."
(espeak-ng -v fr+f5 -s 145 -p 85 "$RESUME_VOCAL" >/dev/null 2>&1) &
