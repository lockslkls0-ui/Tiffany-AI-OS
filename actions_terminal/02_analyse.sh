#!/usr/bin/env bash
# TERM_KEY: analyse
# TERM_DESC: Diagnostic complet matériel et traduction auto des logs en français (0,1s)
# TERM_ICON: 🔍

MODELE=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || echo "Ordinateur Linux")
NOYAU=$(uname -r)
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print int($1/1000)}')
[ -z "$TEMP" ] && TEMP=$(sensors 2>/dev/null | grep -E '(Core 0|CPU|temp1)' | head -n 1 | grep -oE '[0-9]+' | head -n 1)
FREQ=$(awk -F': ' '/cpu MHz/ {print int($2); exit}' /proc/cpuinfo)
GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
[[ "$GOV" == "powersave" ]] && MODE_FR="Mode Froid (économie)" || MODE_FR="Mode Fluide (ondemand)"
LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)

RAM_TOT=$(free -h | awk '/Mem:/ {print $2}' | sed 's/Gi/ Go/; s/Mi/ Mo/')
RAM_USE=$(free -h | awk '/Mem:/ {print $3}' | sed 's/Gi/ Go/; s/Mi/ Mo/')
RAM_DISP=$(free -h | awk '/Mem:/ {print $7}' | sed 's/Gi/ Go/; s/Mi/ Mo/')
SWAP_INFO=$(free -h | awk '/Partition|Swap:/ {print $3 " / " $2}' | sed 's/Gi/ Go/g; s/Mi/ Mo/g')
ZRAM_STAT=$(zramctl --noheadings --output DATA,COMPR 2>/dev/null | awk '{print $1 " compressés en " $2}')

DISK_LIBRE=$(df -h / | awk 'NR==2 {print $4 " libres sur " $2 " (" $5 " utilisés)"}' | sed 's/G/ Go/g')
H_SMART=$(grep "Power_On_Hours" "$HOME/tiffany/logs/sante_disque.txt" 2>/dev/null | awk '{print $NF}')
CRC_SMART=$(grep "UDMA_CRC_Error_Count" "$HOME/tiffany/logs/sante_disque.txt" 2>/dev/null | awk '{print $NF}')
JOURS_SMART=$(( ${H_SMART:-0} / 24 ))

BAT_CAP=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo "100")
BAT_STAT=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1)
[[ "$BAT_STAT" == "Charging" || "$BAT_STAT" == "Full" ]] && SECTEUR="branché sur secteur" || SECTEUR="sur batterie"

WIFI_SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep -E '^(oui|yes)' | cut -d: -f2)
IP_LOC=$(hostname -I | awk '{print $1}')

echo -e "\n\033[1;36m🔍 [ANALYSE COMPLÈTE EN TEMPS RÉEL & AUTO-TRADUCTION FRANÇAISE] :\033[0m"
echo -e "==================================================================="
echo -e " 💻 Machine      : \033[1;32m$MODELE\033[0m (Noyau Linux $NOYAU)"
echo -e " 🌡️ Processeur   : \033[1;33m${TEMP}°C\033[0m à \033[1;36m${FREQ} MHz\033[0m ($MODE_FR)"
echo -e " ⚖️ Charge CPU   : $LOAD"
echo -e " 🧠 Mémoire RAM  : \033[1;32m$RAM_DISP disponibles\033[0m ($RAM_USE utilisés sur $RAM_TOT)"
echo -e " 🚀 Turbo ZRAM   : ${ZRAM_STAT:-Actif} | Swap : $SWAP_INFO"
echo -e " 💾 Disque dur   : $DISK_LIBRE"
[ -n "$H_SMART" ] && echo -e " 📀 Usure SMART  : ${H_SMART} heures (~${JOURS_SMART} jours) | Erreurs câble CRC : ${CRC_SMART:-0}"
echo -e " 🔋 Batterie     : \033[1;32m${BAT_CAP}%\033[0m ($SECTEUR)"
echo -e " 📶 Réseau Wi-Fi : ${WIFI_SSID:-Déconnecté} (IP : ${IP_LOC:-Aucune})"
echo -e "-------------------------------------------------------------------"
echo -e " \033[1;34m🔥 TOP 5 DES APPLICATIONS LES PLUS ACTIVES :\033[0m"
ps -eo comm,%cpu,%mem --sort=-%cpu | grep -vE "^(COMMAND|ps|bash|awk)" | head -n 5 | awk '{printf "   • %-18s | CPU : %5s%% | RAM : %5s%%\n", $1, $2, $3}'
echo -e "-------------------------------------------------------------------"
echo -e " \033[1;35m🩺 JOURNAUX D'ERREURS TRADUITS EN FRANÇAIS :\033[0m"

RESUME_VOCAL=$(python3 - << 'PYEOF'
import subprocess, re

services = subprocess.getoutput("systemctl --failed --no-legend --plain 2>/dev/null").strip().splitlines()
logs = subprocess.getoutput("journalctl -p 3 -n 12 --no-pager -q 2>/dev/null").strip().splitlines()

traductions = [
    (r"I/O error.*sda|blk_update_request", "Erreur de lecture/écriture matérielle sur le disque dur (secteur fatigué ou câble SATA)."),
    (r"Out of memory|Killed process", "Saturation mémoire : Linux a fermé un programme trop gourmand pour éviter le gel."),
    (r"i915|drm.*ERROR", "Micro-erreur d'affichage de la puce graphique Intel (sans gravité)."),
    (r"ACPI Error|ACPI BIOS Error|AE_NOT_FOUND", "Erreur mineure du BIOS ACPI au démarrage (classique sur Toshiba, sans danger)."),
    (r"notify-send.*trap int3", "Une notification graphique a été interrompue lors d'un pic de charge."),
    (r"systemd-journald.*killed", "Le journal système a été purgé automatiquement après une saturation."),
    (r"iwlwifi|ath9k|wlan|NetworkManager.*error", "Coupure ou instabilité temporaire détectée sur la carte Wi-Fi."),
    (r"bluetooth|bluez.*error", "Anomalie temporaire détectée sur le module Bluetooth."),
    (r"usb.*error|device not accepting address", "Un périphérique USB a mal répondu ou a été débranché brusquement."),
    (r"casper-md5check", "Échec de vérification du média d'installation Live (inutile une fois installé)."),
    (r"ollama.*timeout|llama-server", "Le moteur IA local a mis trop de temps à répondre ou a été interrompu.")
]

trouve = 0
for s in services:
    nom_s = s.split()[0]
    print(f"   ⚠️ [Service en échec] {nom_s} ➔ Ce service système ne tourne pas actuellement.")
    trouve += 1

vus = set()
for ligne in logs:
    msg_brut = re.sub(r'^[a-zA-Zéû]+\.\s+\d+\s+[0-9:]+\s+\S+\s+', '', ligne)
    explication = None
    for motif, fr in traductions:
        if re.search(motif, ligne, re.I):
            explication = fr
            break
    if not explication:
        # Traduction mot-à-mot automatique de secours pour les termes anglais courants
        trad = msg_brut
        for en, fr_mot in [("failed", "a échoué"), ("error", "erreur"), ("timeout", "délai dépassé"), ("cannot", "impossible de"), ("not found", "introuvable"), ("denied", "refusé"), ("killed", "arrêté"), ("warning", "avertissement"), ("device", "périphérique"), ("connection", "connexion")]:
            trad = re.sub(r'\b' + en + r'\b', fr_mot, trad, flags=re.I)
        explication = f"Alerte système : {trad[:110]}"
    if explication not in vus:
        vus.add(explication)
        print(f"   • {explication}")
        print(f"     \033[0;90m(Log d'origine : {msg_brut[:95]})\033[0m")
        trouve += 1

if trouve == 0:
    print("   ✅ Aucune erreur détectée dans les journaux système : tout fonctionne parfaitement !")
    print("VOCAL:Aucune erreur détectée dans les journaux système, tout fonctionne parfaitement.", end="")
else:
    print(f"VOCAL:J'ai relevé {trouve} point d'attention dans tes journaux système, tout est affiché en français à l'écran.", end="")
PYEOF
)

# Sépare l'affichage écran de la phrase vocale finale
AFFICHAGE=$(echo "$RESUME_VOCAL" | grep -v "^VOCAL:")
PHRASE_LOG=$(echo "$RESUME_VOCAL" | grep "^VOCAL:" | sed 's/^VOCAL://')

echo -e "$AFFICHAGE"
echo -e "===================================================================\n"

PHRASE_FR="Analyse complète de ton $MODELE : processeur à ${TEMP} degrés, ${RAM_DISP} de mémoire libre, batterie à ${BAT_CAP} pour cent ${SECTEUR}. ${PHRASE_LOG}"
pkill -x espeak-ng >/dev/null 2>&1
(espeak-ng -v fr+f5 -s 145 -p 85 "$PHRASE_FR" >/dev/null 2>&1) &
