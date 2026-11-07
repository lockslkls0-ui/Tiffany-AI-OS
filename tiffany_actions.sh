intercepter_radio() {
    INFOS_MUSIQUE=$(rhythmbox-client --print-playing 2>/dev/null)
    if [ ! -z "$INFOS_MUSIQUE" ] && [ "$INFOS_MUSIQUE" != "Pas de lecture en cours" ]; then
        zenity --info --text="📻 Morceau détecté sur Rhythmbox :\n→ $INFOS_MUSIQUE\n\nTéléchargement sémantique MP3 lancé..." --timeout=4 --title="Tiffany OS"
        yt-dlp -x --audio-format mp3 -o "~/Musique/%(title)s.%(ext)s" "ytsearch1:$INFOS_MUSIQUE"
        zenity --info --text="✅ Téléchargement terminé ! Le MP3 est dans ton dossier Musique." --timeout=3 --title="Tiffany OS"
    else
        zenity --error --text="❌ Rhythmbox ne joue aucune musique ou radio actuellement." --timeout=4 --title="Tiffany OS"
    fi
}

intercepter_radio() {
    INFOS_MUSIQUE=$(rhythmbox-client --print-playing 2>/dev/null)
    if [ ! -z "$INFOS_MUSIQUE" ] && [ "$INFOS_MUSIQUE" != "Pas de lecture en cours" ]; then
        zenity --info --text="📻 Morceau détecté sur Rhythmbox :\n→ $INFOS_MUSIQUE\n\nTéléchargement sémantique MP3 lancé..." --timeout=4 --title="Tiffany OS"
        yt-dlp -x --audio-format mp3 -o "~/Musique/%(title)s.%(ext)s" "ytsearch1:$INFOS_MUSIQUE"
        zenity --info --text="✅ Téléchargement terminé ! Le MP3 est dans ton dossier Musique." --timeout=3 --title="Tiffany OS"
    else
        zenity --error --text="❌ Rhythmbox ne joue aucune musique ou radio actuellement." --timeout=4 --title="Tiffany OS"
    fi
}
#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_actions.sh (Version 48.0 - PRODUCTION STABLE MASTER)
# 🛡️ RÔLE   : Exécution des outils matériels, Radar YouTube et Tâches Futures 'at'
# ==============================================================================
ROOT_DIR="$HOME/tiffany"
LOGS_DIR="$ROOT_DIR/logs"
REQUETE="$*"
REQUETE_CLEAN=$(echo "$REQUETE" | tr 'A-Z' 'a-z' | sed 's/[éèêë]/e/g' | sed 's/[àâ]/a/g')

# 🛡️ 1. SÉCURITÉ MATÉRIELLE : LA CONTRE-BOUCLE COUPE-CIRCUIT CPU
CUP_FOLLE=$(ps -eo pid,%cpu,comm --sort=-%cpu | awk 'NR>1 {if($2>75.0) print $1":"$3}')
if [ -n "$CUP_FOLLE" ]; then
    PID_CIBLE=$(echo "$CUP_FOLLE" | cut -d':' -f1)
    NOM_CIBLE=$(echo "$CUP_FOLLE" | cut -d':' -f2)
    if [[ "$NOM_CIBLE" == "zenity" || "$NOM_CIBLE" == "bash" || "$NOM_CIBLE" == "gnome-terminal-" ]]; then
        kill -9 "$PID_CIBLE" 2>/dev/null
    fi
fi

# 🎛️ 2. L'INTERRUPTEUR D'AIDE ADMINISTRATEUR
if [[ "$REQUETE_CLEAN" == "aide" || "$REQUETE_CLEAN" == "help" ]]; then
    echo -e "\n\033[1;36m📋 PANOPLIE DES OUTILS ADMINISTRATEUR INSTALLÉS (v48.0) :\033[0m"
    echo -e " 🧠 \033[1;32mnoyau\033[0m     : Inventaire complet d'assemblage et état des moteurs d'IA"
    echo -e " 🔎 \033[1;32mradar\033[0m     : Analyse profonde et graphique de l'espace disque"
    echo -e " 🌡️ \033[1;32mcpu\033[0m       : Diagnostic thermique et cadence active en temps réel"
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
    "cpu"|"temp"|"temperature") CMD_GENEREE="gnome-terminal --title='🌡️ Diagnostic CPU' -- bash -c '~/tiffany/tiffany_utilitaire.sh etat_cpu; read'" ;;
    "noyau")                    CMD_GENEREE="gnome-terminal --title='Noyau Tiffany' -- ~/tiffany/tiffany_noyau.sh" ;;
    "ram"|"nettoyer ram")       CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'nettoie_ram' >/dev/null 2>&1" ;;
    "froid")                    CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'refroidissement' 'froid'" ;;
    "boost")                    CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'refroidissement' 'chaud'" ;;
    "corbeille")                CMD_GENEREE="~/tiffany/tiffany_utilitaire.sh 'corbeille'" ;;
    "wifi"|"reseau")            CMD_GENEREE="gnome-terminal --title='📡 Diagnostic Réseau' -- bash -c '~/tiffany/tiffany_utilitaire.sh réseau; read'" ;;
    "heure")                    CMD_GENEREE="~/tiffany/tiffany_outils.sh 'heure'" ;;
    "meteo")                    CMD_GENEREE="~/tiffany/tiffany_outils.sh 'meteo'" ;;
    "analyse")                  CMD_GENEREE="gnome-terminal --title='📊 Analyse Matérielle en Direct' -- bash -c 'sudo lshw -short; echo -e \"\n\n📊 LOGS ET ERREURS SYSTÈME RÉCENTES :\n\"; sudo dmesg | tail -n 15; read'" ;;
 "youtube"|"ouvre youtube")  CMD_GENEREE="google-chrome https://youtube.com &" ;;
"quitter"|"exit")
        if [ -f "$ROOT_DIR/tiffany_core.py" ]; then 
            python3 "$ROOT_DIR/tiffany_core.py" "exit"
        fi
        exit 99 ;;
esac

# 📡 3b. MODULE MULTIMÉDIA - TÉLÉCHARGEMENT RECHERCHE SÉMANTIQUE YT-DLP (v48.0)
if [[ "$REQUETE_CLEAN" =~ "telecharge " ]]; then
    NOM_MORCEAU=$(echo "$REQUETE" | sed -e 's/[Tt]elecharge la musique //g' -e 's/[Tt]elecharge la musique//g' -e 's/[Tt]elecharge //g' | sed 's/^[ \t]*//;s/[ \t]*$//')
    if [ -n "$NOM_MORCEAU" ]; then
        if [[ "$NOM_MORCEAU" =~ ^https?:// ]]; then
            CIBLE_ASPIRATION="$NOM_MORCEAU"
            echo -e "\n📡 🌹 Tiffany : *Aspiration directe lancée en tâche de fond pour ton dossier ~/Musique...*"
        else
            CIBLE_ASPIRATION="ytsearch1:$NOM_MORCEAU"
            echo -e "\n📡 🌹 Tiffany : *Recherche sémantique active et extraction en arrière-plan pour : $NOM_MORCEAU...*"
        fi
        cpulimit -l 50 -- ~/tiffany/yt-dlp -x --audio-format mp3 --audio-quality 192K --no-playlist --default-search "ytsearch" --output "$HOME/Musique/%(title)s.%(ext)s" "$CIBLE_ASPIRATION" >/dev/null 2>&1 &
        exit 0
    else
        echo -e "\n🌹 Tiffany : ❌ Tu ne m'as donné aucun titre à chercher, mon ange."
        exit 0
    fi
fi

# 🕒 3c. MODULE PLANIFICATEUR : COMMANDES DIFFÉRÉES SYSTÈME AVEC 'AT' (v48.0)
if [[ "$REQUETE_CLEAN" =~ "dans " ]]; then
    DELAI=$(echo "$REQUETE_CLEAN" | grep -oP 'dans \K[0-9]+')
    if [ -n "$DELAI" ]; then
        CMD_FUTUR=""
        if [[ "$REQUETE_CLEAN" =~ "ram" || "$REQUETE_CLEAN" =~ "nettoie" ]]; then CMD_FUTUR="~/tiffany/tiffany_utilitaire.sh nettoie_ram"; fi
        if [[ "$REQUETE_CLEAN" =~ "radio" || "$REQUETE_CLEAN" =~ "musique" || "$REQUETE_CLEAN" =~ "coupe" ]]; then CMD_FUTUR="rhythmbox-client --stop"; fi
        
        if [ -n "$CMD_FUTUR" ]; then
            echo "$CMD_FUTUR" | at now + "$DELAI" minutes >/dev/null 2>&1
            echo -e "\n🌹 Tiffany : ✅ C'est programmé Lorian ! J'exécuterai cette action dans exactement $DELAI minutes sur ton Toshiba."
            exit 0
        fi
    fi
fi

# 🔎 4. RADAR DE RECHERCHE FLOU & OUVERTURE DE FICHIERS
if [ -z "$CMD_GENEREE" ]; then
    if [[ "$REQUETE_CLEAN" =~ ^"cherche " || "$REQUETE_CLEAN" =~ ^"trouve " ]]; then
        ~/tiffany/tiffany_fichiers.sh cherche "$REQUETE"
        exit 0
    elif [[ "$REQUETE_CLEAN" =~ ^"ouvre " || "$REQUETE_CLEAN" =~ ^"ouvrir " ]]; then
        ~/tiffany/tiffany_fichiers.sh ouvre "$REQUETE"
        exit 0
    fi
fi

# 🧠 5. INTELLIGENCE OLLAMA LOCALE : TRADUCTION SÉMANTIQUE DES ORDRES ABSOLUE
if [ -z "$CMD_GENEREE" ] && command -v ollama >/dev/null 2>&1; then
    if [[ "$REQUETE_CLEAN" =~ "cree" || "$REQUETE_CLEAN" =~ "supprime" || "$REQUETE_CLEAN" =~ "deplace" || "$REQUETE_CLEAN" =~ "dossier" || "$REQUETE_CLEAN" =~ "fichier" || "$REQUETE_CLEAN" =~ "securise" ]]; then
        echo -e "\n🌹 Tiffany : *Analyse et traduction sémantique de ton ordre...*"
        PROMPT_EXPERT="Tu es l'intelligence système Linux Mint de Tiffany. Traduis l'ordre en français suivant en UNE SEULE ligne de commande Bash valide et exacte (ex: mkdir -p, rm -rf, mv, touch, chmod) pour l'exécuter sur le PC portable. Contrainte absolue : Tu dois IMPÉRATIVEMENT utiliser la variable d'environnement \$HOME pour cibler les dossiers personnels de l'utilisateur (exemple pour le Bureau : \$HOME/Bureau/nom_dossier). N'utilise jamais d'exemples fictifs comme /home/tiffany ou /path/to. S'il s'agit d'un dossier sécurisé, ajoute '&& chmod 700' à la fin du chemin exact. Ne donne AUCUN texte explicatif, aucun commentaire, aucun bloc markdown avec des \`\`\`. Donne uniquement la ligne de commande brute. Demande : '$REQUETE'."
        SORTIE_LLM=$(ollama run qwen2.5:0.5b "$PROMPT_EXPERT" 2>/dev/null)
        CMD_GENEREE=$(echo "$SORTIE_LLM" | sed 's/```bash//g' | sed 's/```//g' | tr -d '`' | sed 's/^[ \t]*//;s/[ \t]*$//' | grep -v '^$' | head -n 1)
    fi
fi

# 🚀 6. PARE-FEU HUMAIN GRAPHIQUE ZENITY & EXÉCUTION SYSTÈME
if [ -n "$CMD_GENEREE" ] && [[ "$CMD_GENEREE" != *"désolé"* && "$CMD_GENEREE" != *"impossible"* ]]; then
    if [[ "$CMD_GENEREE" =~ "mkdir" || "$CMD_GENEREE" =~ "rm " || "$CMD_GENEREE" =~ "mv " || "$CMD_GENEREE" =~ "sudo" || "$CMD_GENEREE" =~ "apt" ]]; then
        echo -e "⚙️  Action administrative détectée : \033[1;33m$CMD_GENEREE\033[0m"
        zenity --question --title="Autorisation Requise - Tiffany AI-OS" --text="Mon Créateur chéri, m'autorises-tu à exécuter cette commande sur ton Toshiba ?\n\n👉 $CMD_GENEREE" --width=460 --timeout=20 2>/dev/null
        if [ $? -eq 0 ]; then
            cpulimit -l 60 -- bash -c "eval $CMD_GENEREE" & wait $!
            echo -e "✅ Action exécutée avec succès mon amour."
            sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null &
        else
            echo -e "❌ Action administrative annulée par le Créateur."
        fi
    else
        cpulimit -l 60 -- bash -c "eval $CMD_GENEREE" >/dev/null 2>&1 & wait $!
    fi
    echo ""
else
    # 💻 PASSERELLE BASH HYBRIDE : Si la commande tapée existe en natif dans Linux Mint, on la lance en direct !
    PREMIER_MOT=$(echo "$REQUETE_CLEAN" | awk '{print $1}')
    if command -v "$PREMIER_MOT" &>/dev/null || [ "$PREMIER_MOT" = "cd" ] || [ "$PREMIER_MOT" = "clear" ]; then
        echo -e "\033[1;30m⚙️  Exécution système de : $REQUETE...\033[0m\n"
        eval "$REQUETE"
    else
        if [ -f "$ROOT_DIR/tiffany_core.py" ]; then
            python3 "$ROOT_DIR/tiffany_core.py" "$REQUETE"
        else
            echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Je n'ai pas pu interpréter cette demande, mon ange...\n"
        fi
    fi
fi


intercepter_radio() {
    # 1. Enregistre le flux audio interne en arrière-plan pendant 5 secondes
    parecord -d alsa_output.pci-0000_00_1b.0.analog-stereo.monitor --channels=1 --file-format=wav /tmp/radio_sample.wav &
    sleep 5
    killall parecord 2>/dev/null
    
    # 2. Identification via Shazam (Songrec)
    if [ -f /tmp/radio_sample.wav ]; then
        songrec recognize /tmp/radio_sample.wav > /tmp/result.json 2>/dev/null
        TITRE_TROUVE=$(jq -r '.track.title + " " + .track.subtitle' /tmp/result.json 2>/dev/null)
    fi
    
    # 3. Téléchargement sémantique automatique sur YouTube
    if [ ! -z "$TITRE_TROUVE" ] && [ "$TITRE_TROUVE" != "null null" ]; then
        zenity --info --text="📻 Musique capturée : $TITRE_TROUVE !\nTéléchargement MP3 en cours..." --timeout=4 --title="Tiffany OS"
        yt-dlp -x --audio-format mp3 -o "~/Musique/%(title)s.%(ext)s" "ytsearch1:$TITRE_TROUVE"
    else
        zenity --error --text="❌ Impossible d'identifier la musique en cours sur la radio." --timeout=4 --title="Tiffany OS"
    fi
    rm -f /tmp/radio_sample.wav /tmp/result.json
}
intercepter_radio() {
    # 1. Demande à Rhythmbox le titre et l'artiste en cours
    INFOS_MUSIQUE=$(rhythmbox-client --print-playing 2>/dev/null)
    
    # 2. Vérifie si Rhythmbox est bien en train de jouer quelque chose
    if [ ! -z "$INFOS_MUSIQUE" ] && [ "$INFOS_MUSIQUE" != "Pas de lecture en cours" ]; then
        zenity --info --text="📻 Morceau détecté sur Rhythmbox :\n→ $INFOS_MUSIQUE\n\nTéléchargement sémantique MP3 lancé..." --timeout=4 --title="Tiffany OS"
        
        # 3. Lance le téléchargement direct sur YouTube
        yt-dlp -x --audio-format mp3 -o "~/Musique/%(title)s.%(ext)s" "ytsearch1:$INFOS_MUSIQUE"
        
        zenity --info --text="✅ Téléchargement terminé ! Le MP3 est dans ton dossier Musique." --timeout=3 --title="Tiffany OS"
    else
        zenity --error --text="❌ Rhythmbox ne joue aucune musique ou radio actuellement." --timeout=4 --title="Tiffany OS"
    fi
}
