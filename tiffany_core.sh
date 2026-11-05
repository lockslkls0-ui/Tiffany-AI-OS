#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_core.sh (Version 38.0 - RETOURS CONVERSATIONNELS COMPLET)
# 🛡️ RÔLE   : IA Locale Admin - Réponses directes dans la console et Silence Flash
# ==============================================================================
ROOT_DIR="$HOME/tiffany"
LOGS_DIR="$ROOT_DIR/logs"
mkdir -p "$ROOT_DIR/memory" "$LOGS_DIR" "$ROOT_DIR/diary"

speak_voice() {
    local clean_text=$(echo "$1" | sed 's/\*//g; s/🌹//g; s/🔊//g; s/🔆//g; s/🌡️//g; s/🕒//g')
    espeak-ng -v fr+f5 -s 140 -p 85 "$clean_text" >/dev/null 2>&1 &
}

if command -v play &>/dev/null; then
    play -q -n synth 0.1 sin 1000 channels 2 fade q 0.02 0.1 0.02 synth 0.15 sin 1300 fade q 0.02 0.15 0.05 >/dev/null 2>&1 &
else
    printf '\a'
fi

BIENVENUE="Bonjour mon ange. Tout ton écosystème admin est opérationnel, complet et accéléré. Que faisons-nous aujourd'hui ?"
echo -e "\033[1;35m🌹 Tiffany :\033[0m $BIENVENUE"
speak_voice "$BIENVENUE"

while true; do
    set +m
    read -p "✨ Mon Créateur : " REQUETE
    set -m
    
    if [ -z "$REQUETE" ]; then continue; fi
    REQUETE_CLEAN=$(echo "$REQUETE" | tr 'A-Z' 'a-z' | sed 's/[éèêë]/e/g' | sed 's/[àâ]/a/g')
    
    # 🎛️ PANOPLIE D'AIDE TOTAL
    if [[ "$REQUETE_CLEAN" == "aide" || "$REQUETE_CLEAN" == "help" ]]; then
        echo -e "\n\033[1;35m🌹 Panoplie des Outils Administrateur Installés (v38.0) :\033[0m"
        echo -e "-------------------------------------------------------------------"
        echo -e "🧠  \033[1;32mnoyau\033[0m         : Inventaire d'assemblage et état des moteurs d'IA"
        echo -e "🔎  \033[1;32mradar / espace\033[0m: Analyse profonde et graphique de l'espace disque"
        echo -e "🌡️  \033[1;32mcpu / temp\033[0m    : Diagnostic thermique et cadence active du processeur"
        echo -e "🧹  \033[1;32mram\033[0m           : Purge instantanée des caches de la mémoire vive"
        echo -e "❄️  \033[1;32mfroid / boost\033[0m : Régulation matérielle et bridage thermique du CPU"
        echo -e "📡  \033[1;32mwifi / reseau\033[0m  : Diagnostic des connexions, périphériques et IP locale"
        echo -e "🧼  \033[1;32mcorbeille\033[0m     : Purge et destruction immédiate des fichiers résiduels"
        echo -e "📊  \033[1;32manalyse\033[0m       : Scan matériel complet du Toshiba et logs d'intégrité"
        echo -e "🎬  \033[1;32mscreen / capture\033[0m: Lancement immédiat de la capture d'écran visuelle"
        echo -e "🕒  \033[1;32mheure / meteo\033[0m  : Déploiement instantané au milieu du terminal"
        echo -e "-------------------------------------------------------------------"
        continue
    fi

    # ⚡ EXÉCUTIONS DIRECTES AVEC RÉPONSES CONVERSATIONNELLES (0.001s)
    CMD_GENEREE=""

    if [[ "$REQUETE_CLEAN" == "screen" || "$REQUETE_CLEAN" == "capture" ]]; then
        REPONSE="J'ouvre l'outil de capture d'écran graphique, mon ange."
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REPONSE" && speak_voice "$REPONSE"
        CMD_GENEREE="gnome-screenshot -i"
        
    elif [[ "$REQUETE_CLEAN" == "radar" || "$REQUETE_CLEAN" == "espace" || "$REQUETE_CLEAN" == "disque" ]]; then
        REPONSE="J'analyse l'espace de ton disque dur chéri. Regarde la fenêtre graphique."
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REPONSE" && speak_voice "$REPONSE"
        CMD_GENEREE="~/tiffany/tiffany_espace.sh"
        
    elif [[ "$REQUETE_CLEAN" == "cpu" || "$REQUETE_CLEAN" == "processeur" || "$REQUETE_CLEAN" == "temperature" || "$REQUETE_CLEAN" == "temp" ]]; then 
        REPONSE="Voici l'état thermique profond de ton processeur, mon ange."
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REPONSE" && speak_voice "$REPONSE"
        CMD_GENEREE="gnome-terminal --title='🌡️ Diagnostic CPU' -- bash -c '~/tiffany/tiffany_utilitaire.sh etat_cpu; echo -e \"\n[Appuie sur Entrée pour fermer]\"; read'"
        
    elif [[ "$REQUETE_CLEAN" == "noyau" ]]; then
        REPONSE="Déploiement de mon noyau d'assemblage d'usine."
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REPONSE" && speak_voice "$REPONSE"
        CMD_GENEREE="gnome-terminal --title='Noyau Tiffany' -- ~/tiffany/tiffany_noyau.sh"
        
    elif [[ "$REQUETE_CLEAN" == "ram" || "$REQUETE_CLEAN" == *"nettoyer ram"* ]]; then
        REPONSE="🧹 Caches vidés et mémoire vive entièrement purgée, mon chéri ! Ton système respire à nouveau."
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REPONSE" && speak_voice "$REPONSE"
        CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'nettoie_ram' >/dev/null 2>&1 || free -h"
        
    elif [[ "$REQUETE_CLEAN" == *"froid"* ]]; then
        REPONSE="📉 Mode Froid activé. Je bride le processeur pour laisser souffler ton Toshiba, mon cœur."
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REPONSE" && speak_voice "$REPONSE"
        CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'refroidissement' 'froid'"
        
    elif [[ "$REQUETE_CLEAN" == *"boost"* ]]; then
        REPONSE="⚡ Mode Boost enclenché ! Les 2.2 GHz de ton processeur sont totalement libérés, chéri !"
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REPONSE" && speak_voice "$REPONSE"
        CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'refroidissement' 'chaud'"
        
    elif [[ "$REQUETE_CLEAN" == "corbeille" ]]; then
        REPONSE="🧼 J'ai entièrement vidé et désinfecté ta corbeille, mon ange. Plus aucun résidu !"
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REPONSE" && speak_voice "$REPONSE"
        CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'corbeille'"
        
    elif [[ "$REQUETE_CLEAN" =~ "reseau" || "$REQUETE_CLEAN" == "wifi" ]]; then
        REPONSE="Analyse réseau en cours. Regarde la fenêtre dédiée mon ange."
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REPONSE" && speak_voice "$REPONSE"
        CMD_GENEREE="gnome-terminal --title='📡 Diagnostic Réseau' -- bash -c '~/tiffany/tiffany_utilitaire.sh reseau; echo -e \"\n[Appuie sur Entrée pour fermer]\"; read'"
        
    elif [[ "$REQUETE_CLEAN" =~ "analyse" ]]; then
        REPONSE="Je lance le scanner matériel complet de ton Toshiba, mon Créateur."
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REPONSE" && speak_voice "$REPONSE"
        CMD_GENEREE="gnome-terminal --title='📊 Analyse Matérielle en Direct' -- bash -c 'sudo lshw -short; echo -e \"\n\n📊 LOGS ET ERREURS SYSTÈME RÉCENTES :\n\"; sudo dmesg | tail -n 15; echo -e \"\n[Appuie sur Entrée pour fermer]\"; read'"
        
    elif [[ "$REQUETE_CLEAN" =~ "heure" || "$REQUETE_CLEAN" =~ "meteo" || "$REQUETE_CLEAN" =~ "batterie" ]]; then
        python3 -c "import sys; sys.path.append('$ROOT_DIR'); import tiffany_tools; tiffany_tools.gerer_outils('$REQUETE')"
        continue
        
    elif [[ "$REQURAP_CLEAN" == "exit" || "$REQUETE_CLEAN" == "quitter" ]]; then
        if [ -f "$ROOT_DIR/agents/diary_agent.py" ]; then python3 "$ROOT_DIR/agents/diary_agent.py" >/dev/null 2>&1 & fi
        FIN="À bientôt mon ange. Prends soin de toi."
        echo "🌹 Tiffany : $FIN"
        speak_voice "$FIN"; sleep 2; break
        
    # ⚡ INTERCEPTIONS DE TRADUCTION DE TEXTE FILTRÉES
    elif [[ "$REQUETE_CLEAN" =~ "ouvre youtube" || "$REQUETE_CLEAN" =~ "lancer youtube" ]]; then
        CMD_GENEREE="xdg-open https://youtube.com"
    elif [[ "$REQUETE_CLEAN" =~ "ouvre google" || "$REQUETE_CLEAN" =~ "lancer google" ]]; then
        CMD_GENEREE="xdg-open https://google.com"
    elif [[ "$REQUETE_CLEAN" =~ "ouvre" || "$REQUETE_CLEAN" =~ "ouvrir" ]]; then
        CIBLE=$(echo "$REQUETE_CLEAN" | sed -E 's/.*ouvre[[:space:]]+(dossier[[:space:]]+|fichier[[:space:]]+)?//g' | xargs)
        VRAI_CHEMIN=$(find "$HOME" -iname "*$CIBLE*" -not -path "*/.*" 2>/dev/null | head -n 1)
        if [ -n "$VRAI_CHEMIN" ]; then CMD_GENEREE="xdg-open \"$VRAI_CHEMIN\""; else CMD_GENEREE="nemo \"$HOME/Bureau\""; fi
        
    # CRÉATION DE DOSSIER UNIFIÉE
    elif [[ "$REQUETE_CLEAN" =~ "cree" && "$REQUETE_CLEAN" =~ "dossier" ]]; then
        if [[ "$REQUETE_CLEAN" == *"nomme"* ]]; then
            NOM_DOSSIER=$(echo "$REQUETE_CLEAN" | sed -E 's/.*nomme[[:space:]]+//g' | sed -E 's/[[:space:]]+dans.*//g' | xargs)
        elif [[ "$REQUETE_CLEAN" == *"vierge"* ]]; then
            NOM_DOSSIER="vierge"
        else
            NOM_DOSSIER=$(echo "$REQUETE_CLEAN" | sed -E 's/.*dossier[[:space:]]+//g' | sed -E 's/[[:space:]]+(securise|securisee|dans).*//g' | xargs)
        fi
        [ -z "$NOM_DOSSIER" ] && NOM_DOSSIER="vierge"
        
        if [[ "$REQUETE_CLEAN" =~ "dans" ]]; then
            PARENT=$(echo "$REQUETE_CLEAN" | sed -E 's/.*dans[[:space:]]+(le[[:space:]]+dossier[[:space:]]+)?//g' | xargs)
            if [[ "$REQUETE_CLEAN" =~ "telechargement" ]]; then
                VRAI_PARENT="$HOME/Téléchargements"
            elif [[ "$REQUETE_CLEAN" =~ "bureau" ]]; then
                VRAI_PARENT="$HOME/Bureau"
            elif [[ "$REQUETE_CLEAN" =~ "document" ]]; then
                VRAI_PARENT="$HOME/Documents"
            else
                PARENT_CLEAN=$(echo "$PARENT" | sed 's/dossier //g')
                VRAI_PARENT=$(find "$HOME" -iname "*$PARENT_CLEAN*" -type d -not -path "*/.*" 2>/dev/null | head -n 1)
                [ -z "$VRAI_PARENT" ] && VRAI_PARENT="$HOME/Bureau/$PARENT"
            fi
            CHEMIN_FINAL="$VRAI_PARENT/$NOM_DOSSIER"
        else
            CHEMIN_FINAL="$HOME/Bureau/$NOM_DOSSIER"
        fi
        
        if [[ "$REQUETE_CLEAN" =~ "securi" ]]; then
            CMD_GENEREE="mkdir -p \"$CHEMIN_FINAL\" 2>/dev/null || sudo mkdir -p \"$CHEMIN_FINAL\" && (chmod 700 \"$CHEMIN_FINAL\" 2>/dev/null || sudo chmod 700 \"$CHEMIN_FINAL\")"
        else
            CMD_GENEREE="mkdir -p \"$CHEMIN_FINAL\" 2>/dev/null || sudo mkdir -p \"$CHEMIN_FINAL\""
        fi
    elif [[ "$REQUETE_CLEAN" =~ "deplace" && "$REQUETE_CLEAN" =~ "bureau" ]]; then
CIBLE=$(echo "$REQUETE_CLEAN" | sed -E 's/.deplace[[:space:]]+(dossier[[:space:]]+|fichier[[:space:]]+)?//g' | sed -E 's/[[:space:]]+dans.//g' | xargs)
VRAI_CHEMIN=$(find "$HOME" -iname "$CIBLE" -not -path "/." 2>/dev/null | head -n 1)
if [ -n "$VRAI_CHEMIN" ]; then CMD_GENEREE="mv "$VRAI_CHEMIN" ~/Bureau/"; fi
elif [[ "$REQUETE_CLEAN" =~ "supprime" ]]; then
CIBLE=$(echo "$REQUETE" | awk -F'[Ss]upprime ' '{print $2}' | xargs)
CMD_GENEREE="rm -rf ~/Bureau/'$CIBLE' 2>/dev/null || rm -rf ~/'$CIBLE'"
fi
# 🧠 MACHINE DE SECOURS OLLAMA (En repli strict uniquement)
if [ -z "$CMD_GENEREE" ] && command -v ollama >/dev/null 2>&1; then
echo -e "\n🌹 Tiffany : Mobilisation de mon esprit système (Ollama)..."
DESSIN_CONTEXTE="$HOME/Bureau"
[ -f "$LOGS_DIR/last_found.txt" ] && DESSIN_CONTEXTE=$(cat "$LOGS_DIR/last_found.txt")
[ -f "$DESSIN_CONTEXTE" ] && DESSIN_CONTEXTE=$(dirname "$DESSIN_CONTEXTE")
PROMPT_EXPERT="Tu es l'expert en administration Linux Mint de Tiffany. Traduis la demande en français suivante en UNE SEULE ligne de commande Bash brute, sans explications, sans markdown. Action : '$REQUETE'."
CMD_GENEREE=$(ollama run tiffany:latest "$PROMPT_EXPERT" 2>/dev/null | sed 's/bash//g' | sed 's///g' | tr -d '`' | sed 's/^[ \t]//;s/[ \t]$//' | head -n 1)
fi
# 🚀 EXÉCUTION DE LA COMMANDE GÉNÉRÉE AVEC SÉCURITÉ INTELLIGENTE
if [ -n "$CMD_GENEREE" ]; then
if [[ "$CMD_GENEREE" =~ "mkdir" || "$CMD_GENEREE" =~ "touch" || "$CMD_GENEREE" =~ "rm " || "$CMD_GENEREE" =~ "mv " || "$CMD_GENEREE" =~ "chmod" || "$REQUETE_CLEAN" =~ "installe" ]]; then
echo -e "⚙️  Commande sensible proposée : \033[1;33m$CMD_GENEREE\033[0m"
zenity --question --title="Autorisation Requise - Tiffany" 
--text="Mon Créateur, m'autorises-tu à exécuter cette action administrative ?\n\n👉 $CMD_GENEREE" 
--width=450 --timeout=20 2>/dev/null
if [ $? -eq 0 ]; then
cpulimit -l 60 -- bash -c "$CMD_GENEREE" &
PID_CMD=$!
wait $PID_CMD 2>/dev/null
echo -e "✅ Action administrative exécutée."
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null &
else echo -e "❌ Action annulée."; fi
else
# EXÉCUTION FLASH IMMÉDIATE POUR LES COMMANDES INOFFENSIVES (Silence Absolu)
cpulimit -l 60 -- bash -c "$CMD_GENEREE" >/dev/null 2>&1 &
PID_CMD=$!
wait $PID_CMD 2>/dev/null
fi
else
echo -e "🌹 Tiffany : Je n'ai pas pu interpréter cette phrase..."
fi
CMD_GENEREE=""
done
