#!/usr/bin/env bash
# TERM_KEY: analyse
# TERM_DESC: Bilan matériel et traduction des logs d erreurs en français (0,1s)
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

# --- 🔍 ANALYSE & TRADUCTION DES LOGS SYSTÈME EN FRANÇAIS PUR (0.05s) ---
SERVICES_HS=$(systemctl --failed --no-legend 2>/dev/null | awk '{print $1}' | xargs)
LOGS_BRUTS=$(journalctl -p 3 -n 15 --no-pager -q 2>/dev/null)
DIAG_FR=()

[ -n "$SERVICES_HS" ] && DIAG_FR+=("Service(s) en erreur : $SERVICES_HS.")
echo "$LOGS_BRUTS" | grep -qiE "I/O error|blk_update_request|sda" && DIAG_FR+=("Attention : erreur de lecture ou d'écriture détectée sur le disque dur sda.")
echo "$LOGS_BRUTS" | grep -qiE "Out of memory|Killed process" && DIAG_FR+=("Alerte mémoire : un programme trop lourd a été fermé par manque de RAM.")
echo "$LOGS_BRUTS" | grep -qiE "i915|drm.*ERROR" && DIAG_FR+=("Micro-erreur d'affichage graphique Intel détectée dans les journaux.")
echo "$LOGS_BRUTS" | grep -qiE "ACPI Error|AE_NOT_FOUND" && DIAG_FR+=("Erreur mineure du BIOS ACPI au démarrage (sans danger).")
echo "$LOGS_BRUTS" | grep -qiE "iwlwifi|ath9k|wlan|NetworkManager.*error" && DIAG_FR+=("Coupure ou instabilité signalée sur la carte Wi-Fi.")
[ "${TEMP:-50}" -ge 78 ] && DIAG_FR+=("Surchauffe : le processeur est chaud à ${TEMP} degrés.")

if [ ${#DIAG_FR[@]} -eq 0 ]; then
    BILAN_SANTE="✅ Aucun problème détecté dans les journaux système : tout est sain."
    VOCAL_SANTE="Aucune erreur détectée dans les journaux système, tout fonctionne parfaitement."
else
    BILAN_SANTE=$(printf "⚠️ %s\n   " "${DIAG_FR[@]}")
    VOCAL_SANTE="Attention, voici ce que j'ai trouvé dans les journaux : ${DIAG_FR[*]}"
fi

echo -e "\n\033[1;36m🔍 [ANALYSE TEMPS RÉEL & LOGS SYSTÈME EN FRANÇAIS] :\033[0m"
echo -e "-------------------------------------------------------------------"
echo -e " 💻 Ordinateur   : \033[1;32m$MODELE\033[0m"
echo -e " 🌡️ Processeur   : \033[1;33m${TEMP}°C\033[0m à \033[1;36m${FREQ} MHz\033[0m ($MODE_FR)"
echo -e " 🔥 Plus gourmand: $TOP_APP"
echo -e " 🧠 Mémoire RAM  : \033[1;32m$RAM_DISP disponibles\033[0m ($RAM_USE utilisés sur $RAM_TOT)"
echo -e " 🚀 Turbo ZRAM   : ${ZRAM_STAT:-Actif}"
echo -e " 💾 Disque dur   : $DISK_LIBRE"
echo -e " 🔋 Batterie     : \033[1;32m${BAT_CAP}%\033[0m ($SECTEUR)"
echo -e " 📶 Réseau Wi-Fi : $WIFI_SSID"
echo -e "-------------------------------------------------------------------"
echo -e " \033[1;35m🩺 ÉTAT DES LOGS & ANOMALIES :\033[0m"
echo -e "   $BILAN_SANTE"
echo -e "-------------------------------------------------------------------\n"

PHRASE_FR="Analyse en temps réel de ton $MODELE : processeur à ${TEMP} degrés, ${RAM_DISP} de mémoire libre, batterie à ${BAT_CAP} pour cent ${SECTEUR}. ${VOCAL_SANTE}"
pkill -x espeak-ng >/dev/null 2>&1
(espeak-ng -v fr+f5 -s 145 -p 85 "$PHRASE_FR" >/dev/null 2>&1) &
