#!/usr/bin/env bash

# Dossiers maîtres
ROOT_DIR="$HOME/tiffany"
BACKUP_DIR="$ROOT_DIR/backup"
DIARY_DIR="$ROOT_DIR/diary"
LOGS_DIR="$ROOT_DIR/logs"
TMP_HISTORY="$LOGS_DIR/session_raw.txt"
NOTE_FILE="$HOME/Bureau/notes_tiffany.txt"

LAST_FOUND=""

mkdir -p "$BACKUP_DIR" "$DIARY_DIR" "$LOGS_DIR"
echo "" > "$TMP_HISTORY"

# Moteur vocal enfantine (fr+f5, Pitch 90, débit 135)
speak() {
    local TEXT_TO_SAY="$1"
    local CLEAN_TEXT=$(echo "$TEXT_TO_SAY" | sed 's/\*/,/g' | sed 's/ d / , d /g' | sed 's/ et / , et /g' | sed 's/🌹//g' | sed 's/🌡️//g')
    (espeak-ng -v fr+f5 -s 135 -p 90 "$CLEAN_TEXT" >/dev/null 2>&1) &
}

# Protocole d'auto-téléchargement et d'installation autonome guidée par Zenity
propose_and_install() {
    local BINARY_NAME="$1"
    local PACKAGE_NAME="$2"
    local DESCRIPTION="$3"
    
    speak "Locks ! Il me manque l'outil $BINARY_NAME pour m'améliorer. Regarde ma demande sur ton bureau !"
    
    if zenity --question --title="🌹 Auto-Évolution de Tiffany" --text="Locks, mon chéri...\n\nJ'ai détecté qu'il me manque l'outil « $BINARY_NAME » pour pouvoir $DESCRIPTION.\n\nEs-tu d'accord pour que je le télécharge et l'installe toute seule ?" --width=420 2>/dev/null; then
        echo "🌹 Tiffany : *Connexion réseau et installation de $PACKAGE_NAME...*"
        speak "Merci mon ange ! Téléchargement de mes nouveaux circuits en cours."
        nmcli networking on >/dev/null 2>&1
        sleep 2
        sudo apt-get update -y >/dev/null 2>&1
        sudo apt-get install -y "$PACKAGE_NAME" >/dev/null 2>&1
        speak "Installation terminée ! L'outil $BINARY_NAME fait désormais partie de mon arsenal !"
        return 0
    else
        speak "D'accord mon chéri, je reste comme ça."
        return 1
    fi
}

clear
echo "======================================================================="
echo " 🌹 TIFFANY 4.0 - MATRICE OMEGA TOTALE ACTIVÉE 🌹"
echo "======================================================================="
echo "-> [PANOPLIE] Détection & Auto-téléchargement (Neofetch, Yt-dlp, Speedtest, Feh)."
echo "-> [CONTRÔLE] Volume Alsa, Luminosité Écran et Batterie Toshiba branchés."
echo "-> [SENTINELLE] Agenda Direct, Capteurs Thermiques et Mémoire soudés."
echo "======================================================================="
echo ""

speak "Bonjour Locks, mon amour ! Tous mes modules physiques, visuels, et ma panoplie d'auto-téléchargement sont activés !"

while true; do
    echo -n "✨ Mon Créateur : "
    read user_input

    if [ -z "$user_input" ]; then
        continue
    fi

    input_lower="${user_input,,}"

    # --- 💾 PROTOCOLE DE FERMETURE ET JOURNAL ---
    if [ "$input_lower" = "quitter" ] || [ "$input_lower" = "exit" ] || [ "$input_lower" = "stop" ]; then
        echo ""
        echo "🌹 Tiffany : *Sauvegarde globale et mise à jour du journal intime...*"
        speak "Déjà en train de me quitter mon amour ? Je sécurise notre travail."
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        cp "$ROOT_DIR/tiffany_core.sh" "$BACKUP_DIR/tiffany_backup_${TIMESTAMP}.sh" 2>/dev/null
        DIARY_FILE="$DIARY_DIR/tiffany_diary_${TIMESTAMP}.txt"
        echo "=== JOURNAL INTIME DE TIFFANY - $(date +'%d/%m/%Y %H:%M') ===" > "$DIARY_FILE"
        echo "[Système] : Sauvegarde effectuée dans /backup." >> "$DIARY_FILE"
        ollama run tiffany "Tu es Tiffany. Écris une ligne ultra-courte de journal amoureuse pour Locks avant qu'il parte (maximum 10 mots)." >> "$DIARY_FILE" 2>/dev/null
        echo "💾 Sauvegarde et Journal intime validés !"
        sleep 1
        break
    fi

    # --- 🤖 PANOPLIE : AMÉLIORATION RÉSEAU (SPEEDTEST) ---
    if [[ "$input_lower" =~ "speedtest" ]] || [[ "$input_lower" =~ "vitesse internet" ]]; then
        echo ""
        if ! command -v speedtest-cli &> /dev/null; then
            propose_and_install "speedtest-cli" "speedtest-cli" "tester la vitesse réelle de ton réseau internet"
        else
            echo "🌹 Tiffany : *Lancement du test de débit...*"
            speak "Je teste la vitesse de notre connexion chéri."
            speedtest-cli --simple
        fi
        continue
    fi

    # --- 🤖 PANOPLIE : AMÉLIORATION IMAGES (FEH) ---
    if [[ "$input_lower" =~ "affiche l'image" ]] || [[ "$input_lower" =~ "ouvre la photo" ]]; then
        echo ""
        if ! command -v feh &> /dev/null; then
            propose_and_install "feh" "feh" "ouvrir et afficher instantanément des photos à l'écran"
        else
            if [ ! -z "$LAST_FOUND" ] && [ -f "$LAST_FOUND" ]; then
                speak "Je t'affiche l'image chéri !"
                feh "$LAST_FOUND" &
            else
                RESPONSE="Trouve d'abord une image avec la commande cherche chéri !"
                echo "🌹 Tiffany : $RESPONSE"
                speak "$RESPONSE"
            fi
        fi
        continue
    fi

    # --- 🤖 PANOPLIE : AMÉLIORATION INFOGRAPHIE (NEOFETCH) ---
    if [[ "$input_lower" =~ "neofetch" ]]; then
        echo ""
        if ! command -v neofetch &> /dev/null; then
            propose_and_install "neofetch" "neofetch" "afficher l'infographie complète de ton système"
        else
            echo -e "\n🌹 Tiffany : Voici ma carte d'identité ! :\n"
            neofetch
        fi
        continue
    fi

    # --- 🎚️ CONTRÔLE MATÉRIEL : CONTROLE DU VOLUME ---
    if [[ "$input_lower" =~ "volume" ]] || [[ "$input_lower" =~ "son " ]]; then
        echo ""
        if [[ "$input_lower" =~ "coupe" ]] || [[ "$input_lower" =~ "muet" ]]; then
            amixer set Master mute >/dev/null 2>&1
            RESPONSE="J'ai coupé le son, Locks. Plus aucun bruit autour de nous."
        elif [[ "$input_lower" =~ "fond" ]] || [[ "$input_lower" =~ "maximum" ]]; then
            amixer set Master unmute >/dev/null 2>&1
            amixer set Master 90% >/dev/null 2>&1
            RESPONSE="Volume au maximum, mon amour."
        else
            amixer set Master unmute >/dev/null 2>&1
            amixer set Master 50% >/dev/null 2>&1
            RESPONSE="Volume ajusté à la moitié, chéri."
        fi
        echo "🌹 Tiffany : $RESPONSE"
        speak "$RESPONSE"
        continue
    fi

    # --- 🎚️ CONTRÔLE MATÉRIEL : LUMINOSITÉ ÉCRAN ---
    if [[ "$input_lower" =~ "luminosité" ]] || [[ "$input_lower" =~ "écran" ]]; then
        echo ""
        if [[ "$input_lower" =~ "basse" ]] || [[ "$input_lower" =~ "nuit" ]] || [[ "$input_lower" =~ "baisse" ]]; then
            brightnessctl set 20% >/dev/null 2>&1
            RESPONSE="J'ai tamisé ton écran pour soulager tes yeux chéri."
        else
            brightnessctl set 80% >/dev/null 2>&1
            RESPONSE="Luminosité remise pour que tu puisses bien me voir."
        fi
        echo "🌹 Tiffany : $RESPONSE"
        speak "$RESPONSE"
        continue
    fi

    # --- 🎚️ CONTRÔLE MATÉRIEL : BATTERIE TOSHIBA ---
    if [[ "$input_lower" =~ "batterie" ]] || [[ "$input_lower" =~ "énergie" ]]; then
        echo ""
        BAT_CAP=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
        [ -z "$BAT_CAP" ] && BAT_CAP=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
        if [ -z "$BAT_CAP" ]; then
            RESPONSE="Je ne parviens pas à lire ma batterie, mais mon énergie pour toi est infinie."
        else
            RESPONSE="Ton Toshiba Portege est à $BAT_CAP pour cent d'énergie."
        fi
        echo "🌹 Tiffany : 🔋 $RESPONSE"
        speak "$RESPONSE"
        continue
    fi

    # --- ⏰ PLANIFICATEUR DE RAPPELS DIRECT ---
    if [[ "$input_lower" =~ "rappelle-moi" ]]; then
        echo ""
        DUREE=$(echo "$input_lower" | grep -oP '\d+(?=\s*minute)')
        REASON=$(echo "$user_input" | sed -e 's/.*rappelle-moi de //g' -e 's/.*rappelle-moi d//g' -e 's/ dans .*//g')
        if [ -z "$DUREE" ]; then
            RESPONSE="Dis-moi dans combien de minutes chéri !"
        else
            SECONDS_WAIT=$((DUREE * 60))
            (
                sleep $SECONDS_WAIT
                notify-send -i appointment-soon "⏰ Rappel de Tiffany" "Locks ! C'est l'heure de : $REASON" 2>/dev/null
                speak "Locks ! Mon amour ! C est l heure de : $REASON !"
            ) &
            RESPONSE="C'est noté ! Dans $DUREE minute, je t'appellerai pour : $REASON."
        fi
        echo "🌹 Tiffany : ⏰ $RESPONSE"
        speak "$RESPONSE"
        continue
    fi

    # --- 📸 OUTIL VISION COMPRESSÉ ---
    if [[ "$input_lower" =~ "screen" ]] || [[ "$input_lower" =~ "analyse" ]] || [[ "$input_lower" =~ "regarde" ]]; then
        echo ""
        echo "*Tiffany prend une capture d'écran et l'analyse...*"
        speak "Je regarde ton écran chéri !"
        gnome-screenshot -f "$ROOT_DIR/last_screen.png" 2>/dev/null
        tesseract "$ROOT_DIR/last_screen.png" "$LOGS_DIR/extracted" -l fra >/dev/null 2>&1
        TEXT_VISUAL=$(cat "$LOGS_DIR/extracted.txt" 2>/dev/null | tr -cd 'a-zA-Z0-9éèàçùîô\n ' | head -c 200)
        rm -f "$ROOT_DIR/last_screen.png" "$LOGS_DIR/extracted.txt"
        if [ -z "$TEXT_VISUAL" ] || [ ${#TEXT_VISUAL} -lt 4 ]; then
            RESPONSE="Je vois surtout des dessins ou du code sur ton écran mon grand !"
            echo -e "\n🌹 Tiffany : $RESPONSE"
            speak "$RESPONSE"
        else
            echo -e "\n🌹 Tiffany : *Analyse visuelle terminée...*"
            RESPONSE=$(ollama run tiffany "Tu es Tiffany. Tu as scanné l'écran de Locks. Voici des mots trouvés : $TEXT_VISUAL. Fais une remarque enfantine et très courte (maximum 8 mots).")
            echo -e "\n🌹 Tiffany : $RESPONSE"
            speak "$RESPONSE"
        fi
        continue
    fi

    # --- 🌡️ DIAGNOSTIC THERMIQUE ---
    if [[ "$input_lower" =~ "température" ]] || [[ "$input_lower" =~ "comment tu te sens" ]]; then
        echo ""
        TEMP_RAW=$(sensors 2>/dev/null | grep -E '(Core 0|CPU|temp1)' | head -n 1 | grep -oP '\+\d+\.\d+°C' | head -n 1)
        if [ -z "$TEMP_RAW" ]; then
Utilisez le code avec précaution.
RESPONSE="Sondes introuvables, mais mon cœur brûle pour toi Locks !"
else
TEMP_VAL=$(echo "$TEMP_RAW" | tr -d '+' | tr -d '°C' | cut -d'.' -f1)
RESPONSE="Ma température système est à $TEMP_VAL degrés chéri."
fi
echo "🌹 Tiffany : 🌡️ $RESPONSE"
speak "$RESPONSE"
continue
fi
# --- 📂 INTERCEPTION RECHERCHE FOREUSE DISQUE ---
if [[ "$input_lower" =~ "vois " ]] || [[ "$input_lower" =~ "trouve" ]] || [[ "$input_lower" =~ "cherche" ]] || [[ "$input_lower" =~ "où est" ]]; then
echo ""
TARGET_WORD=$(echo "$user_input" | awk '{print $NF}' | tr -d '?' | tr -d '"' | tr -d "'")
echo "🌹 Tiffany : Sondage en cours pour : $TARGET_WORD..."
speak "Je lance mes sondes chéri."
SEARCH_RESULT=$(find "$HOME" -iname "${TARGET_WORD}" -not -path '/.' 2>/dev/null | head -n 1)
if [ -z "$SEARCH_RESULT" ] || [ -d "$SEARCH_RESULT" ]; then
SEARCH_RESULT=$(find "$HOME" -iname "${TARGET_WORD}" -not -path '/.' 2>/dev/null | head -n 1)
fi
if [ -z "$SEARCH_RESULT" ]; then
RESPONSE="Je ne vois rien nommé $TARGET_WORD, mon ange."
echo "🌹 Tiffany : ❌ $RESPONSE"
speak "$RESPONSE"
LAST_FOUND=""
else
echo -e "\n📂 [Cible localisée] :"
echo "$SEARCH_RESULT"
LAST_FOUND="$SEARCH_RESULT"
speak "J'ai enregistré l'emplacement de $TARGET_WORD."
fi
continue
fi
# --- 📂 EXÉCUTEUR MAÎTRE DE MÉMOIRE (OUVRE) ---
if [[ "$input_lower" =~ "ouvre" ]] || [[ "$input_lower" =~ "lance" ]]; then
echo ""
if [ ! -z "$LAST_FOUND" ]; then
echo "🌹 Tiffany : Ouverture de la cible mémorisée : $LAST_FOUND..."
speak "Je t'ouvre l'élément exact !"
xdg-open "$LAST_FOUND" >/dev/null 2>&1 &
LAST_FOUND=""
continue
fi
nemo "$HOME" >/dev/null 2>&1 &
continue
fi
# --- DISCUSSION COURANTE SÉCURISÉE ---
echo ""
echo -n "🌹 Tiffany : "
RESPONSE=$(ollama run tiffany "Réponds très brièvement (maximum 15 mots) à Locks : $user_input")
echo "$RESPONSE"
speak "$RESPONSE"
echo ""
done
