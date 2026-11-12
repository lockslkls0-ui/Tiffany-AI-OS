#!/usr/bin/env bash
# ==============================================================================
# 🥋 MODULE : tiffany_training.sh (LE DOJO - ENTRAÎNEMENT SÉCURISÉ EN BAC À SABLE)
# ==============================================================================
ROOT_DIR="$HOME/tiffany"
DOJO_DIR="$ROOT_DIR/dojo"
DICO_IA="$ROOT_DIR/actions_terminal/dictionnaire_ia.txt"
LOG_DOJO="$ROOT_DIR/logs/dojo_training.log"

mkdir -p "$DOJO_DIR"

# 1. Sécurité Thermique : Pause si le processeur dépasse 70°C
TEMP_CPU=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}')
[ -z "$TEMP_CPU" ] && TEMP_CPU=45
if [ "$TEMP_CPU" -gt 70 ]; then
    echo "[$(date '+%H:%M:%S')] 🌡️ Surchauffe ($TEMP_CPU°C). Entraînement reporté." >> "$LOG_DOJO"
    exit 0
fi

# 2. Liste des défis techniques sûrs pour s'entraîner
DEFIS=(
    "affiche les 5 processus qui consomment le plus de memoire|ps aux --sort=-%mem | head -n 6"
    "affiche la taille des dossiers dans le dojo|du -sh ."
    "compte le nombre de fichiers dans le dossier actuel|ls -1 | wc -l"
    "affiche l adresse ip locale|hostname -I"
    "verifie l espace disque libre en megaoctets|df -m /"
)

# Sélection d'un défi au hasard
DEFI_CHOISI=${DEFIS[$RANDOM % ${#DEFIS[@]}]}
ORDRE=$(echo "$DEFI_CHOISI" | cut -d'|' -f1)
CMD_ATTENDUE=$(echo "$DEFI_CHOISI" | cut -d'|' -f2)

# 3. Demande au Gros Cerveau de trouver la commande
PROMPT="Tu es une experte Linux. Donne UNIQUEMENT la commande Bash brute en une ligne pour : '$ORDRE'. Sans texte autour, sans guillemets."
CMD_TEST=$(nice -n 19 timeout 120 ollama run qwen2.5:1.5b "$PROMPT" 2>/dev/null | sed -r 's/```bash//g; s/```//g; s/`//g' | head -n 1 | xargs)

# 4. Bouclier Anti-Destruction (Blocage strict des commandes dangereuses)
if [[ -z "$CMD_TEST" ]] || [[ "$CMD_TEST" =~ (sudo|rm|mv|dd|mkfs|chmod|chown|/etc|/usr|/home|/root|\.\.) ]]; then
    echo "[$(date '+%H:%M:%S')] 🛡️ Rejet sécurité pour '$ORDRE' : $CMD_TEST" >> "$LOG_DOJO"
    exit 1
fi

# 5. Exécution isolée strictement à l'intérieur du Dojo
cd "$DOJO_DIR" || exit 1
eval "$CMD_TEST" >/dev/null 2>&1
CODE_RETOUR=$?

# 6. Validation et Apprentissage dans le dictionnaire officiel
if [ $CODE_RETOUR -eq 0 ]; then
    if ! grep -qi "^${ORDRE}|" "$DICO_IA" 2>/dev/null; then
        echo "${ORDRE}|${CMD_TEST}" >> "$DICO_IA"
        echo "[$(date '+%H:%M:%S')] 🥋 SUCCÈS : '$ORDRE' -> '$CMD_TEST' (Ajouté au dictionnaire)" >> "$LOG_DOJO"
    fi
else
    echo "[$(date '+%H:%M:%S')] ❌ ÉCHEC test : '$CMD_TEST'" >> "$LOG_DOJO"
fi

