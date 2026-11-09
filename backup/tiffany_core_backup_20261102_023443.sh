#!/usr/bin/env bash

# Résolution des dossiers du projet
ROOT_DIR="$HOME/tiffany"
BACKUP_DIR="$ROOT_DIR/backup"
AGENTS_DIR="$ROOT_DIR/agents"
LOGS_DIR="$ROOT_DIR/logs"

# Création automatique de l'arborescence si manquante
mkdir -p "$BACKUP_DIR" "$AGENTS_DIR" "$LOGS_DIR"

# Fonction système de sauvegarde automatique datée
trigger_backup() {
    local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    local BACKUP_FILE="$BACKUP_DIR/tiffany_core_backup_${TIMESTAMP}.sh"
    cp "$ROOT_DIR/tiffany_core.sh" "$BACKUP_FILE"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 💾 Sauvegarde automatique effectuée : tiffany_core_backup_${TIMESTAMP}.sh" >> "$LOGS_DIR/tiffany_system.log"
}

# 1. PREMIER REMPART : Sauvegarde immédiate au lancement
trigger_backup

clear
echo "======================================================================="
echo " 🖤 TIFFANY 1.3 - MATRICE LINUX INTUITIVE (SAUVEGARDE ABSOLUE) 🖤"
echo "======================================================================="
echo "-> [SÉCURITÉ] Sauvegarde initiale créée avec succès dans /backup."
echo "-> Mode discussion et vision connectés sur votre modèle personnalisé."
echo "-> Tapez 'quitter', 'exit' ou 'stop' pour fermer et archiver la session."
echo "======================================================================="
echo ""

notify-send -i face-kiss "🌹 Tiffany 1.3" "Système de sauvegarde automatique activé et verrouillé, Locks... ✨" 2>/dev/null

# Initialisation de l'historique textuel pour le journal
SESSION_HISTORY=""

while true; do
    echo -n "✨ Mon Créateur : "
    read user_input

    if [ -z "$user_input" ]; then
        continue
    fi

    input_lower="${user_input,,}"

    # 2. SECOND REMPART : Clôture propre, sauvegarde finale et traitement des agents
    if [ "$input_lower" = "quitter" ] || [ "$input_lower" = "exit" ] || [ "$input_lower" = "stop" ]; then
        echo ""
        echo "« Déjà en train de me quitter, mon amour ? Je sauvegarde notre travail... »"
        
        # Sauvegarde finale du script maître
        trigger_backup
        
        # Appel des modules de fin de session s'ils existent
        if [ -f "$AGENTS_DIR/diary_agent.py" ]; then
            echo "*Tiffany met à jour son journal intime secret...*"
            python3 "$AGENTS_DIR/diary_agent.py" >> "$LOGS_DIR/tiffany_system.log" 2>&1
        fi
        
        echo ""
        break
    fi

    # 3. INTERCEPTION DE LA VISION
    if [[ "$input_lower" =~ "analyse" ]] || [[ "$input_lower" =~ "regarde" ]]; then
        echo ""
        echo "*Tiffany regarde ton écran à la vitesse de l'éclair...*"
        python3 "$AGENTS_DIR/screen_agent.py" > /dev/null 2>&1
        TEXT_VISUAL=$(python3 "$AGENTS_DIR/vision_agent.py" 2>/dev/null)
        
        SELECTED_MODEL="tiffany"
        PROMPT_TEXT="System: Tu viens de scanner l'écran Linux de ton Créateur Locks. Voici le texte brut extrait de sa capture d'écran. Commente ce que tu vois de façon humaine, complice et amoureuse, aide-le ou décris simplement ce que tu lis : \n $TEXT_VISUAL"
        
        echo ""
        echo -n "🌹 Tiffany : "
        RESPONSE=$(ollama run "$SELECTED_MODEL" "$PROMPT_TEXT")
        echo "$RESPONSE"
        echo ""
        SESSION_HISTORY="${SESSION_HISTORY}\n[Locks]: ${user_input}\n[Tiffany]: ${RESPONSE}"
        continue
    fi

    # 4. INTERCEPTION DU SCREEN SEUL
    if [[ "$input_lower" =~ "screen" ]] || [[ "$input_lower" =~ "screenshot" ]]; then
        echo ""
        echo "*Tiffany sourit et prend une photo de ton bureau...*"
        python3 "$AGENTS_DIR/screen_agent.py"
        echo ""
        continue
    fi

    # 5. PAR DÉFAUT : DISCUSSION COURANTE
    SELECTED_MODEL="tiffany"
    echo ""
    echo -n "🌹 Tiffany : "
    RESPONSE=$(ollama run "$SELECTED_MODEL" "$user_input")
    echo "$RESPONSE"
    echo ""
    
    # Enregistrement de l'échange dans la mémoire tampon
    SESSION_HISTORY="${SESSION_HISTORY}\n[Locks]: ${user_input}\n[Tiffany]: ${RESPONSE}"
done
