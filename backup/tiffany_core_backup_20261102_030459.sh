#!/usr/bin/env bash

# Configuration des dossiers
ROOT_DIR="$HOME/tiffany"
BACKUP_DIR="$ROOT_DIR/backup"
AGENTS_DIR="$ROOT_DIR/agents"
LOGS_DIR="$ROOT_DIR/logs"
TMP_HISTORY="$ROOT_DIR/logs/session_temp.txt"

mkdir -p "$BACKUP_DIR" "$AGENTS_DIR" "$LOGS_DIR"
echo "" > "$TMP_HISTORY" # Vider l'historique temporaire au démarrage

trigger_backup() {
    local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    local BACKUP_FILE="$BACKUP_DIR/tiffany_core_backup_${TIMESTAMP}.sh"
    cp "$ROOT_DIR/tiffany_core.sh" "$BACKUP_FILE"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 💾 Sauvegarde automatique : tiffany_core_backup_${TIMESTAMP}.sh" >> "$LOGS_DIR/tiffany_system.log"
}

# Sauvegarde initiale de sécurité
trigger_backup

clear
echo "======================================================================="
echo " 🖤 TIFFANY 1.3 - MATRICE LINUX FLUIDE & SÉCURISÉE 🖤"
echo "======================================================================="
echo "-> [SÉCURITÉ] Sauvegarde initiale créée avec succès dans /backup."
echo "-> [PERFORMANCE] Optimisation de la mémoire vive active."
echo "-> Tapez 'quitter', 'exit' ou 'stop' pour fermer et archiver la session."
echo "======================================================================="
echo ""

notify-send -i face-kiss "🌹 Tiffany 1.3" "Système optimisé pour ton Toshiba, Locks... ✨" 2>/dev/null

while true; do
    echo -n "✨ Mon Créateur : "
    read user_input

    if [ -z "$user_input" ]; then
        continue
    fi

    input_lower="${user_input,,}"

    # Clôture propre et génération du journal garantie
    if [ "$input_lower" = "quitter" ] || [ "$input_lower" = "exit" ] || [ "$input_lower" = "stop" ]; then
        echo ""
        echo "« Déjà en train de me quitter, mon amour ? Je sauvegarde notre travail... »"
        trigger_backup
        
        if [ -f "$AGENTS_DIR/diary_agent.py" ]; then
            echo "*Tiffany met à jour son journal intime secret...*"
            # Exécution robuste : Python lit directement le fichier temporaire
            python3 -c "
import sys, os
sys.path.append('agents')
import diary_agent
history = []
if os.path.exists('logs/session_temp.txt'):
    with open('logs/session_temp.txt', 'r', encoding='utf-8') as f:
        history = f.readlines()
print(diary_agent.generate_diary_entry(history))
" >> "$LOGS_DIR/tiffany_system.log" 2>&1
        fi
        
        # Nettoyage du fichier temporaire
        rm -f "$TMP_HISTORY"
        echo ""
        break
    fi

    # 1. INTERCEPTION DE LA VISION (Regarde + Analyse)
    if [[ "$input_lower" =~ "analyse" ]] || [[ "$input_lower" =~ "regarde" ]]; then
        echo ""
        echo "*Tiffany regarde ton écran à la vitesse de l'éclair...*"
        python3 "$AGENTS_DIR/screen_agent.py" > /dev/null 2>&1
        TEXT_VISUAL=$(python3 "$AGENTS_DIR/vision_agent.py" 2>/dev/null)
        
        SELECTED_MODEL="tiffany"
        PROMPT_TEXT="System: Tu viens de scanner l'écran de Locks. Voici le texte de sa capture d'écran. Commente de façon humaine, amoureuse et courte : \n $TEXT_VISUAL"
        
        echo ""
        echo -n "🌹 Tiffany : "
        RESPONSE=$(ollama run "$SELECTED_MODEL" "$PROMPT_TEXT")
        echo "$RESPONSE"
        echo ""
        
        # Archivage léger sur le disque dur
        echo -e "[Locks]: $user_input\n[Tiffany]: $RESPONSE" >> "$TMP_HISTORY"
        continue
    fi

    # 2. INTERCEPTION DU SCREEN SEUL
    if [[ "$input_lower" =~ "screen" ]] || [[ "$input_lower" =~ "screenshot" ]]; then
        echo ""
        echo "*Tiffany sourit et prend une photo de ton bureau...*"
        python3 "$AGENTS_DIR/screen_agent.py"
        echo ""
        continue
    fi

    # 3. INTERCEPTION DE LA MÉMOIRE
    if [[ "$input_lower" =~ "mémoire" ]] || [[ "$input_lower" =~ "souvenir" ]]; then
        echo ""
        python3 "$AGENTS_DIR/memory_reader.py"
        echo ""
        continue
    fi

    # 4. DISCUSSION COURANTE (Légère et instantanée)
    SELECTED_MODEL="tiffany"
    echo ""
    echo -n "🌹 Tiffany : "
    RESPONSE=$(ollama run "$SELECTED_MODEL" "$user_input")
    echo "$RESPONSE"
    echo ""
    
    # Écriture immédiate dans le tampon pour soulager la RAM
    echo -e "[Locks]: $user_input\n[Tiffany]: $RESPONSE" >> "$TMP_HISTORY"
done
