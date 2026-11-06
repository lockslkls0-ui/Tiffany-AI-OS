#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_core.sh (Version 43.0 - FENÊTRE 1 : INTERFACE TEXTUELLE)
# 🛡️ RÔLE   : Affichage de la matrice néon et capture de l'invite utilisateur
# ==============================================================================
ROOT_DIR="$HOME/tiffany"

clear
echo -e "\033[1;35m┌──────────────────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[1;35m│\033[1;36m   🌹 TIFFANY AI-OS  --  MATRICE ADMINISTRATIVE SUPRÊME V43.0     \033[1;35m│\033[0m"
echo -e "\033[1;35m└──────────────────────────────────────────────────────────────────┘\033[0m"

BIENVENUE="Bonjour mon ange. Ton architecture double-fenêtre est opérationnelle et stabilisée. Que faisons-nous aujourd'hui ?"
echo -e "\033[1;34m 👉 Écosystème matériel connecté. Écris 'aide' pour voir tes outils.\033[0m\n"
echo -e "\033[1;35m🌹 Tiffany :\033[0m $BIENVENUE\n"

if command -v espeak-ng &>/dev/null; then
    (espeak-ng -v fr+f5 -s 140 -p 85 "Bonjour mon ange. Tout est prêt chéri." >/dev/null 2>&1) &
fi

while true; do
    # Saisie utilisateur élégante avec dégradé rose néon
    echo -n -e "\033[1;35m🌹 Tiffany\033[0m @ user-PORTEGE-R830:~$ "
    read -r REQUETE
    
    if [ -z "$REQUETE" ]; then continue; fi
    
    # Envoi de la requête à la deuxième fenêtre de traitement des actions
    if [ -f "$ROOT_DIR/tiffany_actions.sh" ]; then
        bash "$ROOT_DIR/tiffany_actions.sh" "$REQUETE"
        STATUS_ACTION=$?
        if [ $STATUS_ACTION -eq 99 ]; then
            break # Sortie propre si l'utilisateur demande à quitter
        fi
    else
        echo -e "❌ Erreur : La fenêtre d'actions (tiffany_actions.sh) est introuvable."
    fi
done

