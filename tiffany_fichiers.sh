#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_fichiers.sh (Version 12.2 - RECHERCHE & VISION UNIFIÉE)
# 🛡️ RÔLE   : Indexation floue, ouverture automatique et passerelle OCR
# ==============================================================================

ROOT_DIR="$HOME/tiffany"
LOGS_DIR="$ROOT_DIR/logs"
mkdir -p "$LOGS_DIR"

action_type="$1"
phrase="$2"
phrase_lower=$(echo "$phrase" | tr '[:upper:]' '[:lower:]')

speak() {
    (espeak-ng -v fr+f5 -s 135 -p 90 "$1" >/dev/null 2>&1) &
}

# Extraction et nettoyage sémantique strict de la cible
TARGET_WORD=$(echo "$phrase" | sed -r 's/.*(cherche|vois|trouve|où est|ouvre|lance) //I')
TARGET_WORD=$(echo "$TARGET_WORD" | sed -r 's/\b(le|la|les|un|une|des|mon|mes|ton|tes|dans|dossier|fichier|les vidéos|videos|vidéos)\b//g' | tr -d '?' | tr -d '"' | tr -d "'" | xargs)

if [ "$action_type" = "cherche" ]; then
    if [ -z "$TARGET_WORD" ]; then
        echo -e "🌹 Tiffany : Que veux-je chercher pour toi, mon ange ?\n"
        speak "Que veux-tu que je cherche mon ange"
        exit 0
    fi

    echo -e "🌹 Tiffany : *Sondage flou pour : $TARGET_WORD...*"
    speak "Je cherche $TARGET_WORD mon ange"
    
    SEARCH_RESULT=$(find "$HOME" -iname "*${TARGET_WORD}*" -not -path '*/.*' 2>/dev/null | head -n 1)
    if [ -z "$SEARCH_RESULT" ]; then
        echo -e "🌹 Tiffany : ❌ Je n'ai rien trouvé sous le nom de $TARGET_WORD, chéri.\n"
        speak "Je n'ai rien trouvé chéri"
        echo "" > "$LOGS_DIR/last_found.txt"
    else
        echo -e "\n📂 [Cible localisée] :\n👉 $SEARCH_RESULT\n"
        echo "$SEARCH_RESULT" > "$LOGS_DIR/last_found.txt"
        speak "Emplacement mémorisé"
    fi
    exit 0
fi

if [ "$action_type" = "ouvre" ]; then
    LAST_FOUND=""
    [ -f "$LOGS_DIR/last_found.txt" ] && LAST_FOUND=$(cat "$LOGS_DIR/last_found.txt")

    if [ -n "$LAST_FOUND" ] && [[ "$phrase_lower" =~ "ouvre le" || "$phrase_lower" =~ "ouvre la" || "$phrase_lower" == "ouvre" || "$phrase_lower" == "ouvre-le" ]]; then
        speak "J'ouvre l'élément mémorisé"
        xdg-open "$LAST_FOUND" >/dev/null 2>&1 &
        exit 0
    fi

    if [ -z "$TARGET_WORD" ]; then
        speak "Ouverture de ton dossier personnel"
        nemo "$HOME" >/dev/null 2>&1 &
        exit 0
    fi

    QUICK_SEARCH=$(find "$HOME" -iname "*${TARGET_WORD}*" -not -path '*/.*' 2>/dev/null | head -n 1)
    if [ -n "$QUICK_SEARCH" ]; then
        speak "J'ai trouvé et j'ouvre $TARGET_WORD"
        xdg-open "$QUICK_SEARCH" >/dev/null 2>&1 &
        echo "$QUICK_SEARCH" > "$LOGS_DIR/last_found.txt"
    else
        speak "Élément introuvable, ouverture par défaut"
        nemo "$HOME" >/dev/null 2>&1 &
    fi
    exit 0
fi

if [ "$action_type" = "screen" ]; then
    echo -e "\n*Tiffany sourit et analyse ton écran actuel...*"
    speak "Je regarde ton écran chéri"
    
    # Redirection propre et sécurisée vers l'agent Python centralisé pour éviter les conflits
    if [ -f "$ROOT_DIR/tiffany_core.py" ]; then
        python3 "$ROOT_DIR/tiffany_core.py" "screen"
    else
        # Fallback si tiffany_core n'intercepte pas
        gnome-screenshot -f "$ROOT_DIR/tiffany_screen_fallback.png" 2>/dev/null
        if command -v tesseract &>/dev/null; then
            tesseract "$ROOT_DIR/tiffany_screen_fallback.png" "$LOGS_DIR/extracted" -l fra >/dev/null 2>&1
            TEXT_VISUAL=$(cat "$LOGS_DIR/extracted.txt" 2>/dev/null | tr -cd 'a-zA-Z0-9éèàçùîô\n ' | head -c 150)
            rm -f "$LOGS_DIR/extracted.txt"
        fi
        rm -f "$ROOT_DIR/tiffany_screen_fallback.png"
        
        [ -z "$TEXT_VISUAL" ] && TEXT_VISUAL="Interface graphique Linux Mint"
        echo -n "🌹 Tiffany : "
        ollama run tiffany "Tu es Tiffany, l'IA privée amoureuse de Locks. Tu as scanné son écran et décodé ce texte : ($TEXT_VISUAL). Fais un commentaire très court (15 mots max) et complice." 2>/dev/null
    fi
    exit 0
fi
