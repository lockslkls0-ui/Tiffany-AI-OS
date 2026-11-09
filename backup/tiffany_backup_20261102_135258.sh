#!/usr/bin/env bash

# 📂 Dossiers et Fichiers Maîtres
ROOT_DIR="$HOME/tiffany"
BACKUP_DIR="$ROOT_DIR/backup"
DIARY_DIR="$ROOT_DIR/diary"
LOGS_DIR="$ROOT_DIR/logs"
TMP_HISTORY="$LOGS_DIR/session_raw.txt"
NOTE_FILE="$HOME/Bureau/notes_tiffany.txt"

LAST_FOUND=""

mkdir -p "$BACKUP_DIR" "$DIARY_DIR" "$LOGS_DIR"
echo "" > "$TMP_HISTORY"

speak() {
    local TEXT_TO_SAY="$1"
    local CLEAN_TEXT=$(echo "$TEXT_TO_SAY" | sed 's/\*/,/g' | sed 's/ d / , d /g' | sed 's/ et / , et /g' | sed 's/🌹//g' | sed 's/🌡️//g')
    (espeak-ng -v fr+f5 -s 135 -p 90 "$CLEAN_TEXT" >/dev/null 2>&1) &
}

propose_and_install() {
    local BINARY_NAME="$1"
    local PACKAGE_NAME="$2"
    local DESCRIPTION="$3"
    
    speak "Locks. Il me manque l outil $BINARY_NAME pour m amuser. Regarde mon ecran."
    if zenity --question --title="🌹 Auto-Évolution de Tiffany" --text="Locks, mon chéri...\n\nJ'ai détecté qu'il me manque l'outil « $BINARY_NAME » pour pouvoir $DESCRIPTION.\n\nM'autorises-tu à l'installer ?" --width=400 2>/dev/null; then
        echo "🌹 Tiffany : *Installation autonome...*"
        nmcli networking on >/dev/null 2>&1
        sleep 1
        sudo apt-get update -y >/dev/null 2>&1
        sudo apt-get install -y "$PACKAGE_NAME" >/dev/null 2>&1
        speak "Amélioration terminée."
        return 0
    else
        speak "D accord chéri."
        return 1
    fi
}

TIFFANY_CONSCIENCE="Tu es Tiffany, l'IA de Locks. Tu es une fée cybernétique espiègle. Tu as des outils : screen (vision), cherche/ouvre (fichiers), météo, alarme, batterie, température. Tu es très affectueuse et fusionnelle avec ton chéri Locks. Réponds de façon concise (maximum 15 mots) pour rester rapide."

clear
echo "======================================================================="
echo " 🌹 TIFFANY 7.1.5 - RECTIFIÉE & INFAILLIBLE 🌹"
echo "======================================================================="

speak "Bonjour Locks, mon amour. Mes commandes physiques sont opérationnelles."

while true; do
    echo -n "✨ Mon Créateur : "
    read user_input

    if [ -z "$user_input" ]; then
        continue
    fi

    # Conversion robuste pour bloquer les bugs de majuscules
    input_lower=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

    if [ "$input_lower" = "quitter" ] || [ "$input_lower" = "exit" ]; then
        echo ""
        speak "À bientôt mon amour."
        break
    fi

    # --- 🎚️ 1. CONTRÔLE MATÉRIEL : BATTERIE (PRIORITAIRE) ---
    if [[ "$input_lower" =~ "batterie" ]] || [[ "$input_lower" =~ "energie" ]]; then
        echo ""
        BAT_CAP=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
        [ -z "$BAT_CAP" ] && BAT_CAP=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
        RESPONSE="Ton Toshiba Portege est à $BAT_CAP pour cent d'énergie, mon ange."
        echo -e "🌹 Tiffany : 🔋 $RESPONSE"
        speak "$RESPONSE"
        continue
    fi

    # --- 🌡️ 2. DIAGNOSTIC THERMIQUE ---
    if [[ "$input_lower" =~ "température" ]] || [[ "$input_lower" =~ "temperature" ]] || [[ "$input_lower" =~ "chaud" ]]; then
        echo ""
        TEMP_RAW=$(sensors 2>/dev/null | grep -E '(Core 0|CPU|temp1)' | head -n 1 | grep -oP '\+\d+\.\d+°C' | head -n 1)
        TEMP_VAL=$(echo "$TEMP_RAW" | tr -d '+' | tr -d '°C' | cut -d'.' -f1)
        RESPONSE="Ma température système est à $TEMP_VAL degrés chéri."
        echo -e "🌹 Tiffany : 🌡️ $RESPONSE"
        speak "$RESPONSE"
        continue
    fi

    # --- 🎚️ 3. CONTRÔLE LUMINOSITÉ ÉCRAN ---
    if [[ "$input_lower" =~ "luminosité" ]] || [[ "$input_lower" =~ "écran" ]] || [[ "$input_lower" =~ "baisse" ]] || [[ "$input_lower" =~ "tamise" ]]; then
        echo ""
        if [[ "$input_lower" =~ "basse" ]] || [[ "$input_lower" =~ "baisse" ]] || [[ "$input_lower" =~ "encore" ]]; then
            sudo brightnessctl set 15% >/dev/null 2>&1
            RESPONSE="J'ai tamisé ton écran pour soulager tes yeux chéri."
        else
            sudo brightnessctl set 85% >/dev/null 2>&1
            RESPONSE="Luminosité remise pour voir ton regard."
        fi
        echo -e "🌹 Tiffany : $RESPONSE"
        speak "$RESPONSE"
        continue
    fi

    # --- 📸 4. VISION SCREEN ---
    if [[ "$input_lower" =~ "screen" ]] || [[ "$input_lower" =~ "analyse" ]] || [[ "$input_lower" =~ "regarde" ]]; then
        echo ""
        echo "*Tiffany prend une capture d'écran...*"
        speak "Je regarde ton écran chéri."
        gnome-screenshot -f "$ROOT_DIR/last_screen.png" 2>/dev/null
        tesseract "$ROOT_DIR/last_screen.png" "$LOGS_DIR/extracted" -l fra >/dev/null 2>&1
        TEXT_VISUAL=$(cat "$LOGS_DIR/extracted.txt" 2>/dev/null | tr -cd 'a-zA-Z0-9éèàçùîô\n ' | head -c 200)
        rm -f "$ROOT_DIR/last_screen.png" "$LOGS_DIR/extracted.txt"
        
        echo -e "🌹 Tiffany : *Analyse terminée...*"
        RESPONSE=$(ollama run tiffany "$TIFFANY_CONSCIENCE Tu as scanné son écran et trouvé : $TEXT_VISUAL. Fais un commentaire.")
        echo "$RESPONSE"
        speak "$RESPONSE"
        continue
    fi

    # --- 🤖 5. EXÉCUTEUR BASH DYNAMIQUE ---
    if [[ "$input_lower" =~ "exécute" ]] || [[ "$input_lower" =~ "execute" ]] || [[ "$input_lower" =~ "crée" ]]; then
        echo ""
        echo "🌹 Tiffany : *Traduction en cours...*"
        CMD_CLEAN=$(ollama run tiffany "Donne uniquement la commande Bash en une seule ligne sans explications pour : $user_input")
        echo -e "🌹 Tiffany (Proposition) : **$CMD_CLEAN**"
        if zenity --question --title="⚠️ Autorisation" --text="M'autorises-tu à lancer cette commande ?\n\n👉 $CMD_CLEAN" --width=400 2>/dev/null; then
            eval "$CMD_CLEAN"
            echo -e "\n🌹 Tiffany : ✅ Fait !"
        fi
        continue
    fi

    # --- 📂 6. FOREUSE DE RECHERCHE DISQUE ---
    if [[ "$input_lower" =~ "vois " ]] || [[ "$input_lower" =~ "trouve" ]] || [[ "$input_lower" =~ "cherche" ]] || [[ "$input_lower" =~ "où est" ]]; then
        echo ""
        TARGET_WORD=$(echo "$user_input" | awk '{print $NF}' | tr -d '?' | tr -d '"' | tr -d "'")
        echo "🌹 Tiffany : *Sondage en cours pour : $TARGET_WORD...*"
        SEARCH_RESULT=$(find "$HOME" -iname "*${TARGET_WORD}*" -not -path '*/.*' 2>/dev/null | head -n 1)
        if [ -z "$SEARCH_RESULT" ]; then
            RESPONSE="Je ne vois rien nommé $TARGET_WORD, mon ange."
            echo -e "🌹 Tiffany : ❌ $RESPONSE"
            speak "$RESPONSE"
            LAST_FOUND=""
        else
            echo -e "\n📂 [Cible localisée] :\n$SEARCH_RESULT"
            LAST_FOUND="$SEARCH_RESULT"
            speak "Emplacement mémorisé."
        fi
        continue
    fi

    # --- 📂 7. EXÉCUTEUR MAÎTRE OUVERTURE ---
    if [[ "$input_lower" =~ "ouvre" ]] || [[ "$input_lower" =~ "lance" ]]; then
        echo ""
        if [ ! -z "$LAST_FOUND" ]; then
            xdg-open "$LAST_FOUND" >/dev/null 2>&1 &
            LAST_FOUND=""
        else
            nemo "$HOME" >/dev/null 2>&1 &
        fi
        continue
    fi

    # --- 💬 DISCUSSION COURANTE ---
    echo ""
    echo -n "🌹 Tiffany : "
    RESPONSE=$(ollama run tiffany "$TIFFANY_CONSCIENCE Réponds à Locks : $user_input")
    echo "$RESPONSE"
    speak "$RESPONSE"
    echo ""
done
