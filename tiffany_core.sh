#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_core.sh (Version 46.1 - PRODUCTION FINALE LIBÉRÉE)
# 🛡️ RÔLE   : Affichage de la matrice néon, invite et passation synchrone
# ==============================================================================
ROOT_DIR="$HOME/tiffany"

clear
echo -e "\033[1;35m┌──────────────────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[1;35m│\033[1;36m   🌹 TIFFANY AI-OS  --  MATRICE ADMINISTRATIVE SUPRÊME V46.1     \033[1;35m│\033[0m"
echo -e "\033[1;35m└──────────────────────────────────────────────────────────────────┘\033[0m"

BIENVENUE="Bonjour mon ange. Tout ton écosystème d'automatisation, la contre-boucle anti-bug et les journaux de bord sont alignés. Que faisons-nous aujourd'hui ?"
echo -e "\033[1;34m 👉 Écosystème matériel connecté. Écris 'aide' pour voir ta panoplie.\033[0m\n"
echo -e "\033[1;35m🌹 Tiffany :\033[0m $BIENVENUE\n"

if command -v espeak-ng &>/dev/null; then
    (espeak-ng -v fr+f5 -s 140 -p 85 "Bonjour mon ange. Tout est opérationnel chéri." >/dev/null 2>&1) &
fi

while true; do
    echo -n -e "\033[1;35m🌹 Tiffany\033[0m @ user-PORTEGE-R830:~$ "
    read -r REQUETE
    
    if [ -z "$REQUETE" ]; then continue; fi
    
    if [ -f "$ROOT_DIR/tiffany_actions.sh" ]; then
        # IMPORTANT : On retire le 2>/dev/null global pour laisser à la requête HTTP d'Ollama le temps de s'exécuter jusqu'au bout
        bash "$ROOT_DIR/tiffany_actions.sh" "$REQUETE"
        STATUS_ACTION=$?
        
        if [ $STATUS_ACTION -eq 99 ]; then
            echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Session clôturée de mon côté. À tout de suite mon amour."
            break
        fi
    else
        echo -e "\033[1;31m❌ Erreur d'ADN : Le moteur d'actions (tiffany_actions.sh) est introuvable chéri.\033[0m"
    fi
done

