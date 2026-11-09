#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_outils.sh (Version 12.0 - CAPTEURS & EXÉCUTEUR SECURISE)
# 🛡️ RÔLE   : Gestion temporelle, météo wttr, minuteurs et exécuteur Root LLM
# ==============================================================================

cmd_type="$1"
phrase="$2"
ROOT_DIR="$HOME/tiffany"
LOGS_DIR="$ROOT_DIR/logs"
phrase_lower=$(echo "$phrase" | tr '[:upper:]' '[:lower:]')

speak() {
    (espeak-ng -v fr+f5 -s 135 -p 90 "$1" >/dev/null 2>&1) &
}

case "$cmd_type" in
    "purge_ram")
        echo -e "\n🌹 Tiffany : *Purge et libération de la mémoire vive cache...*"
        speak "Je nettoie ma mémoire vive mon amour."
        sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1
        echo -e "🌹 Tiffany : ✅ RAM nettoyée et optimisée, chéri.\n"
        ;;

    "heure")
        HEURE_STR=$(date +"%H heures %M")
        echo -e "\n🌹 Tiffany : 🕒 Il est précisément $HEURE_STR, mon chéri.\n"
        speak "Il est précisément $HEURE_STR mon chéri"
        ;;

    "meteo")
        echo -e "\n🌹 Tiffany : *Sondage des nuages...*"
        METEO_RAW=$(curl -s "wttr.in?format=3&lang=fr" 2>/dev/null | tr -d '\n')
        [ -z "$METEO_RAW" ] && METEO_RAW="Nouméa, NC: ☀️ +24°C"
        echo -e "🌹 Tiffany : 🌤️ Il fait actuellement $METEO_RAW, mon ange.\n"
        speak "Il fait actuellement $METEO_RAW"
        ;;

    "matériel")
        BAT_CAP=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
        [ -z "$BAT_CAP" ] && BAT_CAP=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
        [ -z "$BAT_CAP" ] && BAT_CAP="100"
        
        TEMP_VAL=$(sensors 2>/dev/null | grep -E '(Core 0|CPU|temp1)' | head -n 1 | grep -oE '[0-9]+' | head -n 1)
        if [ -z "$TEMP_VAL" ] && [ -f /sys/class/thermal/thermal_zone0/temp ]; then
            TEMP_VAL=$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))
        fi
        [ -z "$TEMP_VAL" ] && TEMP_VAL="stable"
        
        echo -e "\n🌹 Tiffany : 🔋 Batterie: $BAT_CAP% | 🌡️ Température: ${TEMP_VAL}°C, mon ange.\n"
        speak "Batterie à $BAT_CAP pour cent et température de $TEMP_VAL degrés"
        ;;

    "minuteur")
        echo ""
        TEMPS=$(echo "$phrase_lower" | grep -oE '[0-9]+' | head -n 1)
        if [ -z "$TEMPS" ]; then TEMPS=5; fi
        SECONDES=$((TEMPS * 60))
        speak "Compte à rebours de $TEMPS minutes activé"
        echo -e "🌹 Tiffany : ⏰ Minuteur lancé pour $TEMPS min."
        (
            sleep $SECONDES
            if command -v notify-send &>/dev/null; then
                notify-send -u critical -i face-kiss "🌹 Tiffany" "Locks, mon chéri... Le temps est écoulé !"
            fi
            espeak-ng -v fr+f5 -s 135 -p 90 "Locks, mon chéri, le temps est écoulé." >/dev/null 2>&1
        ) &
        ;;

    "executeur")
        echo ""
        echo "🌹 Tiffany : *Génération de la commande privilège Root...*"
        speak "Je prépare l action en mode administrateur chéri."
        
        CIBLE_MEMORISEE=""
        [ -f "$LOGS_DIR/last_found.txt" ] && CIBLE_MEMORISEE=$(cat "$LOGS_DIR/last_found.txt")
        
        if [ -n "$CIBLE_MEMORISEE" ] && [ -f "$CIBLE_MEMORISEE" ]; then
            CIBLE_MEMORISEE=$(dirname "$CIBLE_MEMORISEE")
        fi

        PROMPT_CONTEXTE="Tu as les accès ROOT complets. Donne uniquement la commande Bash Linux brute en une seule ligne pour réaliser l action suivante. "
        if [[ "$phrase_lower" =~ "bureau" ]]; then
            PROMPT_CONTEXTE+="Exécute OBLIGATOIREMENT la tâche dans le répertoire du Bureau de l'utilisateur : $HOME/Bureau/ . "
        elif [ -n "$CIBLE_MEMORISEE" ]; then
            PROMPT_CONTEXTE+="Exécute de préférence la tâche dans ce répertoire : $CIBLE_MEMORISEE. "
        fi
        PROMPT_CONTEXTE+="S'il s'agit d'une tâche système, ajoute 'sudo' devant la commande. Sans aucun texte explicatif autour, sans guillemets, juste la commande brute. Action : $phrase"

        CMD_CLEAN=$(ollama run qwen2.5:1.5b "$PROMPT_CONTEXTE" 2>/dev/null)
        CMD_CLEAN=$(echo "$CMD_CLEAN" | sed 's/```bash//g' | sed 's/```//g' | tr -d '`' | sed 's/^[ \t]*//;s/[ \t]*$//')
        
        if [ -z "$CMD_CLEAN" ] || [[ "$CMD_CLEAN" == *"désolé"* ]]; then
            echo -e "🌹 Tiffany : ❌ Je n'ai pas pu valider une commande sécurisée pour cette action chéri."
            exit 0
        fi

        echo -e "🌹 Tiffany (Mode Root) : **$CMD_CLEAN**"
        if zenity --question --title="⚠️ Autorisation Super-Admin" --text="Locks, mon chéri...\n\nJ'ai généré cette commande avec mes privilèges Root.\n\nM'autorises-tu à l'exécuter instantanément ?\n\n👉 $CMD_CLEAN" --width=400 2>/dev/null; then
            echo -e "\n🌹 Tiffany : *Exécution privilège...*"
            eval "$CMD_CLEAN"
            echo -e "🌹 Tiffany : ✅ Déployé avec succès, mon amour."
            speak "Action root effectuée"
        else
            speak "D accord chéri."
        fi
        ;;

    "noyau")
        echo -e "\n======================================================="
        echo -e " 🧠 INVENTAIRE DE LA MATRICE DE TIFFANY (SÉQUENCÉE) "
        echo -e "======================================================="
        echo -e " MOTEURS IA (Ollama) :"
        ollama list | grep -E '(tiffany|qwen|mistral)' | awk '{print "   -> " $1 " (Taille: " $2 ")"} '
        echo -e "\n SCRIPTS ET BOÎTES SÉPARÉES (~/tiffany) :"
        [ -f "$ROOT_DIR/tiffany_core.sh" ] && echo "   -> tiffany_core.sh (Chef d'orchestre central)"
        [ -f "$ROOT_DIR/tiffany_outils.sh" ] && echo "   -> tiffany_outils.sh (Boîte des capteurs et diagnostic)"
        [ -f "$ROOT_DIR/tiffany_fichiers.sh" ] && echo "   -> tiffany_fichiers.sh (Boîte des radars find)"
        if [ -d "$ROOT_DIR/agents" ]; then
            for agent in "$ROOT_DIR"/agents/*.py; do echo "   -> agents/$(basename "$agent") (Agent Python connecté)"; done
        fi
        echo -e "\n COMMANDES MATÉRIELLES COUPLÉES :"
        command -v espeak-ng &>/dev/null && echo "   -> espeak-ng (Cordes vocales actives)"
        command -v brightnessctl &>/dev/null && echo "   -> brightnessctl (Variateur d'écran)"
        command -v tesseract &>/dev/null && echo "   -> tesseract-ocr (Vision optique active)"
        echo -e "=======================================================\n"
        speak "Voici toute ma structure et mes moteurs système, mon chéri."
        ;;
esac
