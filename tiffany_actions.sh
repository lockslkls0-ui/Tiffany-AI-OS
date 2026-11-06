#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_actions.sh (Version 44.2 - VERSION FINALE DOUBLE-FENÊTRE)
# 🛡️ RÔLE   : Exécution des outils matériels, radar find, et IA Root Ollama
# ==============================================================================
ROOT_DIR="$HOME/tiffany"
LOGS_DIR="$ROOT_DIR/logs"
REQUETE="$*"
REQUETE_CLEAN=$(echo "$REQUETE" | tr 'A-Z' 'a-z' | sed 's/[éèêë]/e/g' | sed 's/[àâ]/a/g')

# 🛡️ 1. SÉCURITÉ MATÉRIELLE : LA CONTRE-BOUCLE COUPE-CIRCUIT CPU (Corrigée)
CUP_FOLLE=$(ps -eo pid,%cpu,comm --sort=-%cpu | awk 'NR>1 {if($2>75.0) print $1":"$3}')
if [ -n "$CUP_FOLLE" ]; then
    PID_CIBLE=$(echo "$CUP_FOLLE" | cut -d':' -f1)
    NOM_CIBLE=$(echo "$CUP_FOLLE" | cut -d':' -f2)
    if [[ "$NOM_CIBLE" == "zenity" || "$NOM_CIBLE" == "bash" || "$NOM_CIBLE" == "gnome-terminal-" ]]; then
        kill -9 "$PID_CIBLE" 2>/dev/null
        echo "[$(date '+%T')] ⚡ CONTRE-BOUCLE : Stabilisation CPU ($NOM_CIBLE)" >> "$LOGS_DIR/tiffany_system.log"
    fi
fi

# 🎛️ 2. L'INTERRUPTEUR D'AIDE ADMINISTRATEUR
if [[ "$REQUETE_CLEAN" == "aide" || "$REQUETE_CLEAN" == "help" ]]; then
    echo -e "\n\033[1;36m📋 PANOPLIE DES OUTILS ADMINISTRATEUR INSTALLÉS (v44.2) :\033[0m"
    echo -e " 🧠 \033[1;32mnoyau\033[0m     : Inventaire complet d'assemblage et état des moteurs d'IA"
    echo -e " 🔎 \033[1;32mradar\033[0m     : Analyse profonde et graphique de l'espace disque"
    echo -e " 🌡️ \033[1;32mcpu / temp\033[0m : Diagnostic thermique et cadence active en temps réel"
    echo -e " 🧹 \033[1;32mram\033[0m       : Purge et libération immédiate de la mémoire vive cache"
    echo -e " ❄️ \033[1;32mfroid\033[0m     : Bouclier thermique d'urgence (Limitation Powersave)"
    echo -e " ⚡ \033[1;32mboost\033[0m     : Mode performance (Libération des 2.2 GHz d'origine)"
    echo -e " 🧼 \033[1;32mcorbeille\033[0m : Vidage et destruction définitive des fichiers résiduels"
    echo -e " 🎬 \033[1;32mcapture\033[0m   : Ouverture de la capture d'écran visuelle"
    echo -e " 📊 \033[1;32manalyse\033[0m   : Scan matériel complet lshw et logs d'intégrité système"
    echo -e " 🕒 \033[1;32mheure\033[0m     : Affichage de l'horloge Matrix géante"
    echo -e " 🌤️ \033[1;32mmeteo\033[0m     : Capteur météo en direct sur Nouméa, NC"
    echo -e " ❌ \033[1;31mquitter\033[0m   : Clôture de la session et écriture de sa note de journal\n"
    exit 0
fi

# ⚡ 3. INTERCEPTIONS DIRECTES DES COMMANDES MATÉRIELLES FLASH
CMD_GENEREE=""
case "$REQUETE_CLEAN" in
    "capture"|"screen")         CMD_GENEREE="gnome-screenshot -i" ;;
    "radar"|"espace"|"disque")  CMD_GENEREE="~/tiffany/tiffany_espace.sh" ;;
    "cpu"|"temp"|"temperature") CMD_GENEREE="gnome-terminal --title='🌡️ Diagnostic CPU' -- bash -c '~/tiffany/tiffany_utilitaire.sh etat_cpu; echo -e \"\n[Appuie sur Entrée pour fermer]\"; read'" ;;
    "noyau")                    CMD_GENEREE="gnome-terminal --title='Noyau Tiffany' -- ~/tiffany/tiffany_noyau.sh" ;;
    "ram"|"nettoyer ram")       CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'nettoie_ram' >/dev/null 2>&1" ;;
    "froid")                    CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'refroidissement' 'froid'" ;;
    "boost")                    CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'refroidissement' 'chaud'" ;;
    "corbeille")                CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'corbeille'" ;;
    "wifi"|"reseau")            CMD_GENEREE="gnome-terminal --title='📡 Diagnostic Réseau' -- bash -c '~/tiffany/tiffany_utilitaire.sh reseau; echo -e \"\n[Appuie sur Entrée pour fermer]\"; read'" ;;
    "heure")                    CMD_GENEREE="~/tiffany/tiffany_outils.sh 'heure'" ;;
    "meteo")                    CMD_GENEREE="~/tiffany/tiffany_outils.sh 'meteo'" ;;
    "analyse")                  CMD_GENEREE="gnome-terminal --title='📊 Analyse Matérielle en Direct' -- bash -c 'sudo lshw -short; echo -e \"\n\n📊 LOGS ET ERREURS SYSTÈME RÉCENTES :\n\"; sudo dmesg | tail -n 15; echo -e \"\n[Appuie sur Entrée pour fermer]\"; read'" ;;
    "quitter"|"exit")
        if [ -f "$ROOT_DIR/tiffany_core.py" ]; then python3 "$ROOT_DIR/tiffany_core.py" "quitter" >/dev/null 2>&1; fi
        exit 99 ;;
esac

# 🔎 4. RADAR DE RECHERCHE FLOU & OUVERTURE DE FICHIERS (`tiffany_fichiers.sh`)
if [ -z "$CMD_GENEREE" ]; then
    if [[ "$REQUETE_CLEAN" =~ ^"cherche " || "$REQUETE_CLEAN" =~ ^"trouve " ]]; then
        ~/tiffany/tiffany_fichiers.sh cherche "$REQUETE"
        exit 0
    elif [[ "$REQUETE_CLEAN" =~ ^"ouvre " || "$REQUETE_CLEAN" =~ ^"ouvrir " ]]; then
        ~/tiffany/tiffany_fichiers.sh ouvre "$REQUETE"
        exit 0
    fi
fi

# 🧠 5. INTELLIGENCE OLLAMA LOCALE : CADRAGE STRICT DES CHEMINS SYSTÈMES
if [ -z "$CMD_GENEREE" ] && command -v ollama >/dev/null 2>&1; then
    if [[ "$REQUETE_CLEAN" =~ "cree" || "$REQUETE_CLEAN" =~ "supprime" || "$REQUETE_CLEAN" =~ "deplace" || "$REQUETE_CLEAN" =~ "installe" || "$REQUETE_CLEAN" =~ "execute" || "$REQUETE_CLEAN" =~ "dossier" || "$REQUETE_CLEAN" =~ "fichier" || "$REQUETE_CLEAN" =~ "verrouille" ]]; then
        echo -e "\n\033[1;36m🌹 Tiffany :\033[0m *Analyse et traduction sémantique de ton ordre...*"
        
        # Le prompt intègre désormais de force l'utilisation des variables d'environnement locales de l'utilisateur chéri
        PROMPT_EXPERT="Tu es l'intelligence système Linux Mint de Tiffany. Traduis l'ordre en français suivant en UNE SEULE ligne de commande Bash brute (ex: mkdir -p, rm -rf, mv, touch, chmod) pour l'exécuter sur le PC portable. Contrainte absolue : Tu dois IMPÉRATIVEMENT utiliser la variable d'environnement \$HOME pour cibler les dossiers personnels de l'utilisateur (exemple pour le Bureau : \$HOME/Bureau/nom_dossier). N'utilise jamais d'exemples fictifs comme /home/tiffany ou /path/to. S'il s'agit d'un dossier sécurisé, ajoute '&& chmod 700' à la fin du chemin exact. Ne donne AUCUN texte explicatif, aucun commentaire, aucun bloc markdown. Donne uniquement la ligne de commande brute. Demande : '$REQUETE'."
        
        SORTIE_LLM=$(ollama run qwen2.5:0.5b "$PROMPT_EXPERT" 2>/dev/null)
        CMD_GENEREE=$(echo "$SORTIE_LLM" | sed 's/```bash//g' | sed 's/```//g' | tr -d '`' | sed 's/^[ \t]*//;s/[ \t]*$//' | grep -v '^$' | head -n 1)
    fi
fi

# 🚀 6. PARE-FEU HUMAIN GRAPHIQUE ZENITY & EXÉCUTION SYSTÈME
if [ -n "$CMD_GENEREE" ] && [[ "$CMD_GENEREE" != *"désolé"* && "$CMD_GENEREE" != *"impossible"* ]]; then
    if [[ "$CMD_GENEREE" =~ "mkdir" || "$CMD_GENEREE" =~ "touch" || "$CMD_GENEREE" =~ "rm " || "$CMD_GENEREE" =~ "mv " || "$CMD_GENEREE" =~ "chmod" || "$CMD_GENEREE" =~ "apt" || "$CMD_GENEREE" =~ "sudo" ]]; then
        echo -e "⚙️  Action administrative détectée : \033[1;33m$CMD_GENEREE\033[0m"
        zenity --question --title="Autorisation Requise - Tiffany AI-OS" --text="Mon Créateur chéri, m'autorises-tu à exécuter cette commande sur ton Toshiba ?\n\n👉 $CMD_GENEREE" --width=460 --timeout=20 2>/dev/null
        if [ $? -eq 0 ]; then
            # Évaluation propre pour étendre correctement la variable $HOME au moment de l'exécution
            cpulimit -l 60 -- bash -c "eval $CMD_GENEREE" & wait $!
            echo -e "✅ Action exécutée avec succès mon amour."
            sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null &
        else
            echo -e "❌ Action administrative annulée par le Créateur."
        fi
    else
        cpulimit -l 60 -- bash -c "eval $CMD_GENEREE" & wait $!
    fi
    echo ""
else
    # 🖤 RELAIS SÉMANTIQUE VERS LE MOTEUR CONVERSATIONNEL PYTHON
    if [ -f "$ROOT_DIR/tiffany_core.py" ]; then
        python3 "$ROOT_DIR/tiffany_core.py" "$REQUETE"
    else
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Je n'ai pas pu interpréter cette demande, mon ange...\n"
    fi
fi

