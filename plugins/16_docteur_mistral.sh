#!/usr/bin/env bash
# MENU_NAME: 🩺 Docteur Mistral (Audit Total)
# MENU_DESC: Passe tous les diagnostics et propose une réparation via Zenity

LOG_MISTRAL="$HOME/tiffany/logs/audit_mistral.log"
notify-send -u low -t 3500 -i "system-run" "🩺 Docteur Mistral" "Scan complet des 5 capteurs lancé en arrière-plan..." >/dev/null 2>&1

# 1. Collecte rapide des 5 diagnostics
ERR_NOYAU=$(dmesg -l err,crit 2>/dev/null | tail -n 5)
ERR_SERVICES=$(systemctl --failed --no-legend 2>/dev/null)
SANTE_DISK=$(sudo -n smartctl -H /dev/sda 2>/dev/null | grep -i "result" || df -h / | tail -n 1)
ERR_PAQUETS=$(dpkg --audit 2>/dev/null)
WD_ACTIF=$(systemctl --user is-active tiffany-watchdog.service 2>/dev/null | grep -q "^active$" && echo "ACTIF" || echo "INACTIF")
TEMP_CPU=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print int($1/1000)}')

RAPPORT_BRUT="Watchdog: $WD_ACTIF | Temp: ${TEMP_CPU}°C | Disque: $SANTE_DISK | Services HS: ${ERR_SERVICES:-Aucun} | Paquets: ${ERR_PAQUETS:-OK} | Noyau: ${ERR_NOYAU:-Rien}"
PROMPT="Tu es l'ingénieur Linux expert de Tiffany. Analyse ce bilan : [$RAPPORT_BRUT]. Résume l'état réel en 3 lignes courtes en français sans répéter les données brutes. Termine par une ligne exacte 'CMD: commande' pour réparer le souci principal (ajoute pkexec si droits root requis, ou 'CMD: echo Tout est sain')."

REPONSE=$(nice -n 19 timeout 300 cpulimit -q -l 60 -- ollama run qwen2.5-coder:1.5b "$PROMPT" 2>/dev/null)
echo -e "=== AUDIT DU $(date) ===\n$REPONSE\n" >> "$LOG_MISTRAL"
CMD_PROPOSEE=$(echo "$REPONSE" | grep "^CMD:" | tail -n 1 | sed 's/^CMD://' | xargs)
[ -z "$CMD_PROPOSEE" ] && CMD_PROPOSEE="echo Aucune action requise"

zenity --question --title="🩺 Diagnostic Complet Docteur Mistral" --text="$REPONSE\n\n👉 Autoriser : $CMD_PROPOSEE ?" --width=550 2>/dev/null

if [ $? -eq 0 ]; then
    eval "$CMD_PROPOSEE"
    zenity --info --title="🩺 Docteur Mistral" --text="✅ Intervention effectuée !" --timeout=3 2>/dev/null
fi
