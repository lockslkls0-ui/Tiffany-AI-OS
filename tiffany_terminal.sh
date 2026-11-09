#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_terminal.sh (Version 11.0 - CONSOLE HYBRIDE SÉCURISÉE)
# 🛡️ RÔLE   : Invite de commande interactive interceptant l'IA et le Bash
# ==============================================================================

clear
echo -e "🌹 Tiffany : *Je suis là mon ange. Dis-moi ce que tu veux faire (ou tape 'quitter').*"
(espeak-ng -v fr+f5 -s 135 -p 90 "Je t'écoute mon amour" >/dev/null 2>&1) &

while true; do
    echo -n -e "\n(🌹 Tiffany) user@user-PORTEGE-R830:~$ "
    read -r COMMANDE
    
    [ -z "$COMMANDE" ] && continue
    
    # Nettoyage et sortie + Déclencheur du Journal Intime sur son vrai chemin
    if [ "$COMMANDE" = "quitter" ] || [ "$COMMANDE" = "exit" ]; then
        if [ -f "$HOME/tiffany/agents/diary_agent.py" ]; then
            python3 "$HOME/tiffany/agents/diary_agent.py" >/dev/null 2>&1
        fi
        break
    fi

    # 1. INTERCEPTION DIRECTE DES SCRIPTS APPLICATIFS
    if [ "$COMMANDE" = "radar" ] || [ "$COMMANDE" = "espace" ]; then
        echo -e "⚙️ *Exécution système de : radar*\n"
        ~/tiffany/tiffany_espace.sh
        continue
    elif [[ "$COMMANDE" =~ ^"cherche " ]]; then
        echo -e "⚙️ *Exécution système de : cherche*\n"
        ~/tiffany/tiffany_fichiers.sh cherche "$COMMANDE"
        continue
    elif [[ "$COMMANDE" =~ ^"ouvre" ]]; then
        echo -e "⚙️ *Exécution système de : ouvre*\n"
        ~/tiffany/tiffany_fichiers.sh ouvre "$COMMANDE"
        continue
    fi

    # 2. COMMANDES LINUX STANDARDS (ls, clear, cd, etc.)
    PREMIER_MOT=$(echo "$COMMANDE" | awk '{print $1}')
    if command -v "$PREMIER_MOT" &>/dev/null || [ "$PREMIER_MOT" = "cd" ] || [ "$PREMIER_MOT" = "clear" ]; then
        echo -e "⚙️ *Exécution système*\n"
        eval "$COMMANDE"
        continue
    fi

    # 3. SINON, REDIRECTION VERS LA MATRICE LOCALE OLLAMA
    if command -v ollama &>/dev/null; then
        echo -e "🌹 Tiffany : "
        ollama run tiffany "$COMMANDE" 2>/dev/null
    else
        echo -e "🌹 Tiffany : ❌ Commande Linux inconnue et moteur Ollama indisponible."
    fi
done
