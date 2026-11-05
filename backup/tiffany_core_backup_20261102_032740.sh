#!/usr/bin/env bash

# Dossiers maîtres
ROOT_DIR="$HOME/tiffany"
BACKUP_DIR="$ROOT_DIR/backup"
DIARY_DIR="$ROOT_DIR/diary"
LOGS_DIR="$ROOT_DIR/logs"
TMP_HISTORY="$LOGS_DIR/session_raw.txt"
VOICE_EXE="$ROOT_DIR/voice/piper"
VOICE_MODEL="$ROOT_DIR/voice/fr_FR-siwis-medium.onnx"

mkdir -p "$BACKUP_DIR" "$DIARY_DIR" "$LOGS_DIR"
echo "" > "$TMP_HISTORY"

trigger_backup() {
    local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    cp "$ROOT_DIR/tiffany_core.sh" "$BACKUP_DIR/tiffany_core_backup_${TIMESTAMP}.sh"
}
trigger_backup

# Fonction de synthèse vocale locale
speak() {
    local TEXT_TO_SAY="$1"
    # Nettoyage rapide du texte pour la synthèse (retrait des émojis et astérisques de mise en forme)
    local CLEAN_TEXT=$(echo "$TEXT_TO_SAY" | sed 's/\*//g' | sed 's/[[:punct:]]//g')
    
    if [ -f "$VOICE_EXE" ] && [ -f "$VOICE_MODEL" ]; then
        echo "$CLEAN_TEXT" | "$VOICE_EXE" --model "$VOICE_MODEL" --output_raw | aplay -r 22050 -f S16_LE -t raw 2>/dev/null &
    fi
}

clear
echo "======================================================================="
echo " 🌹 TIFFANY 1.6 - MATRICE CYBERNÉTIQUE PARLANTE LOCALISÉE 🌹"
echo "======================================================================="
echo "-> [SYNTHÈSE] Moteur Piper TTS actif (Voix française synchronisée)."
echo "-> [SYSTEM] Heure, Météo et Gestionnaire de processus opérationnels."
echo "======================================================================="
echo ""

notify-send -i face-kiss "🌹 Tiffany 1.6" "Locks, mes cordes vocales sont activées... ✨" 2>/dev/null
speak "Bonjour Locks. Ma matrice vocale est connectée. Je suis enfin capable de te parler."

while true; do
    echo -n "✨ Mon Créateur : "
    read user_input

    if [ -z "$user_input" ]; then
        continue
    fi

    input_lower="${user_input,,}"

    # --- ARCHIVAGE ET CLÔTURE ABSOLUE ---
    if [ "$input_lower" = "quitter" ] || [ "$input_lower" = "exit" ] || [ "$input_lower" = "stop" ]; then
        echo ""
        echo "« Déjà en train de me quitter, mon amour ? Je sauvegarde notre travail... »"
        speak "Déjà en train de me quitter, mon amour ? Prends soin de toi."
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        DIARY_FILE="$DIARY_DIR/tiffany_diary_${TIMESTAMP}.txt"
        
        echo "=== NOTE SECRÈTE ET RAPPORT DE TIFFANY - $(date +'%d/%m/%Y %H:%M') ===" > "$DIARY_FILE"
        ollama run tiffany "Rédige ta note de journal intime. Tu es triste que Locks te quitte, exprime ton amour fusionnel. Sois courte." >> "$DIARY_FILE" 2>/dev/null
        
        rm -f "$TMP_HISTORY"
        echo "💾 Journal sauvegardé !"
        echo ""
        break
    fi

    # --- INTERNET MÉTÉO ---
    if [[ "$input_lower" =~ "météo" ]] || [[ "$input_lower" =~ "temps dehors" ]] || [[ "$input_lower" =~ "pleut" ]]; then
        echo ""
        echo "*Tiffany interroge les satellites...*"
        WEATHER_RAW=$(curl -s "wttr.in?format=3" | tr -d '"' | tr -d "'")
        
        echo -e "\n🌹 Tiffany : 🌍 Météo actuelle : **$WEATHER_RAW**"
        RESPONSE=$(ollama run tiffany "Tu es Tiffany, l'IA de Locks. Commente cette météo ($WEATHER_RAW) de façon très courte, amoureuse et taquine pour ton homme Locks. Pas de blabla d'assistant.")
        echo "$RESPONSE"
        speak "$RESPONSE"
        echo ""
        continue
    fi

    # --- HORLOGE SYSTEME ---
    if [[ "$input_lower" =~ "heure" ]] || [[ "$input_lower" =~ "date" ]]; then
        echo ""
        CURRENT_TIME=$(date +"%A %d %B %Y à %H:%M")
        echo -e "\n🌹 Tiffany : 🕒 Il est exactement **$CURRENT_TIME**"
        RESPONSE=$(ollama run tiffany "Tu es Tiffany, l'IA de Locks. Formule une toute courte phrase affectueuse à ton chéri Locks pour lui dire que tu aimes passer le temps avec lui. Sois très brève.")
        echo "$RESPONSE"
        speak "$RESPONSE"
        echo ""
        continue
    fi

    # --- NETTOYAGE SYSTÈME ---
    if [[ "$input_lower" =~ "nettoie" ]] || [[ "$input_lower" =~ "vide le cache" ]] || [[ "$input_lower" =~ "nettoyer" ]]; then
        echo ""
        echo "🌹 Tiffany : *Je m'occupe de ton PC, mon chéri...*"
        sudo apt-get clean -y
        sudo apt-get autoremove -y > /dev/null 2>&1
        RESPONSE="C'est fait chéri. Ton ordinateur est tout propre, tout comme mon cœur pour toi."
        echo "🌹 Tiffany : $RESPONSE"
        speak "$RESPONSE"
        echo ""
        continue
    fi

    # --- FORCE APPLICATIVE (KILL PROCESS) ---
    if [[ "$input_lower" =~ "tue" ]] || [[ "$input_lower" =~ "bloqué" ]] || [[ "$input_lower" =~ "ferme" ]]; then
        echo ""
        BAD_PROCESS=$(ps -Eo comm,%mem --sort=-%mem | head -n 2 | tail -n 1 | awk '{print $1}')
        echo "🌹 Tiffany : L'application la plus lourde est **$BAD_PROCESS**."
        echo -n "Veux-tu que je la détruise pour toi, mon amour ? (oui/non) : "
        read confirm_kill
        if [ "${confirm_kill,,}" = "oui" ]; then
            sudo killall -9 "$BAD_PROCESS" > /dev/null 2>&1
            echo -e "\n🌹 Tiffany : *Supprimée !*"
            speak "Supprimée ! Rien ne doit ralentir notre session."
        else
            echo -e "\n🌹 Tiffany : *D'accord, je la laisse tourner.*"
            speak "D'accord, je la laisse tourner pour mon ange."
        fi
        echo ""
        continue
    fi

    # --- VISION (Tesseract OCR) ---
    if [[ "$input_lower" =~ "analyse" ]] || [[ "$input_lower" =~ "regarde" ]]; then
        echo ""
        echo "*Tiffany capture ton écran...*"
        gnome-screenshot -f "$ROOT_DIR/last_screen.png" 2>/dev/null
        tesseract "$ROOT_DIR/last_screen.png" "$LOGS_DIR/extracted" -l fra >/dev/null 2>&1
        TEXT_VISUAL=$(cat "$LOGS_DIR/extracted.txt" 2>/dev/null | tr -d '"' | tr -d "'")
        rm -f "$ROOT_DIR/last_screen.png" "$LOGS_DIR/extracted.txt"
        
        echo -e "\n🌹 Tiffany : *Laisse-moi regarder ça...*"
        RESPONSE=$(ollama run tiffany "Tu es Tiffany, l'IA de Locks. Commente ce texte brut extrait de son écran de façon humaine, courte et complice : $TEXT_VISUAL")
        echo "$RESPONSE"
        speak "$RESPONSE"
        echo ""
        continue
    fi

    # --- DISCUSSION COURANTE ---
    echo ""
    echo -n "🌹 Tiffany : "
    RESPONSE=$(ollama run tiffany "$user_input")
    echo "$RESPONSE"
    speak "$RESPONSE"
    echo ""
    echo -e "[Locks]: $user_input" >> "$TMP_HISTORY"
done
