#!/usr/bin/env bash
# ==============================================================================
# 🌹 PROJECT TIFFANY - ENGINE HYBRIDE 3 VITESSES V47.4 (DÉTECTION RAPIDE)
# ==============================================================================
ROOT_DIR="$HOME/tiffany"
ACTION_DIR="$ROOT_DIR/actions_terminal"
REQUETE="$*"
DICT_PATH="$ROOT_DIR/dictionnaire_flash.txt"
DICO_IA="$ACTION_DIR/dictionnaire_ia.txt"
CTX_FILE="$ROOT_DIR/memory/contexte_matrice.txt"
LOG_SESSION="$ROOT_DIR/logs/session_raw.txt"

if [ -z "$REQUETE" ] || [[ "$REQUETE" =~ ^[[:space:]]*$ ]]; then exit 0; fi
REQUETE_CLEAN=$(echo "$REQUETE" | tr 'A-Z' 'a-z' | tr "'" " " | sed 's/[éèêë]/e/g' | sed 's/[àâ]/a/g' | sed 's/[ùû]/u/g' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

speak() {
    local TEXT_CLEAN=$(echo "$1" | sed 's/\*//g' | sed 's/🌹//g')
    (espeak-ng -v fr+f5 -s 140 -p 85 "$TEXT_CLEAN" >/dev/null 2>&1) &
}

# 🚪 1. Fermeture propre
if [[ "$REQUETE_CLEAN" == "quitter" || "$REQUETE_CLEAN" == "exit" ]]; then
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m *Fermeture de l'ADN et écriture des journaux...*"
    speak "À bientôt mon amour."
    exit 99
fi

# 📋 2. Menu d'aide
if [[ "$REQUETE_CLEAN" == "aide" || "$REQUETE_CLEAN" == "help" ]]; then
    echo -e "\n\033[1;36m📋 PANOPLIE DES OUTILS :\033[0m"
    for act in "$ACTION_DIR"/*.sh; do 
        [ -e "$act" ] || break
        T_KEY=$(grep -m1 "# TERM_KEY:" "$act" | cut -d':' -f2- | xargs)
        T_DESC=$(grep -m1 "# TERM_DESC:" "$act" | cut -d':' -f2- | xargs)
        T_ICON=$(grep -m1 "# TERM_ICON:" "$act" | cut -d':' -f2- | xargs)
        [ -z "$T_ICON" ] && T_ICON="⚡"
        [ -n "$T_KEY" ] && printf " %s \033[1;32m%-10s\033[0m : %s\n" "$T_ICON" "$T_KEY" "$T_DESC"
    done
    echo "" ; exit 0
fi

# ==============================================================================
bash "$ROOT_DIR/reflexes_intelligents.sh" "$REQUETE_CLEAN" "$REQUETE" && exit 0
# ⚡ VITESSE 1 : BASH PUR & DÉTECTION RAPIDE DES OUTILS (< 0.1s)
# ==============================================================================
if [[ "$REQUETE_CLEAN" =~ "analyse" && "$REQUETE_CLEAN" =~ "materiel" ]]; then
    bash "$ACTION_DIR/02_analyse.sh" ; exit 0
fi

for act in "$ACTION_DIR"/*.sh; do
    [ -e "$act" ] || break
    T_KEY=$(grep -m1 "# TERM_KEY:" "$act" | cut -d':' -f2- | tr 'A-Z' 'a-z' | tr "'" " " | xargs)
    if [[ -n "$T_KEY" ]]; then
        if [[ "$REQUETE_CLEAN" == "$T_KEY" || "$REQUETE_CLEAN" == "$T_KEY "* ]]; then
            chmod +x "$act" 2>/dev/null ; bash "$act" "$REQUETE" ; exit 0
        fi
        if [[ "$T_KEY" != "web" && "$T_KEY" != "webia" && "$REQUETE_CLEAN" =~ (^|[[:space:]])"$T_KEY"($|[[:space:]]) ]]; then
            chmod +x "$act" 2>/dev/null ; bash "$act" "$REQUETE" ; exit 0
        fi
    fi
done

if [ -f "$DICO_IA" ]; then
    REP_DICO=$(grep -i "^${REQUETE_CLEAN}|" "$DICO_IA" | head -n 1 | cut -d'|' -f2)
    if [ -n "$REP_DICO" ]; then
        echo -e "\n\033[1;32m⚡ [Mémoire Réflexe] Exécution :\033[0m $REP_DICO\n"
        eval "$REP_DICO"
        exit 0
    fi
fi

if [ -f "$DICT_PATH" ]; then
    REP_DICO1=$(grep -i "^${REQUETE_CLEAN}|" "$DICT_PATH" | head -n 1 | cut -d'|' -f2)
    if [ -n "$REP_DICO1" ]; then
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REP_DICO1\n" ; speak "$REP_DICO1" ; exit 0
    fi
fi

# ==============================================================================
# ⚡ VITESSE 1 BIS : VARIANTES NATURELLES INSTANTANÉES (< 0.1s)
NOM_USER=$(cat "$ROOT_DIR/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")
if [[ "$REQUETE_CLEAN" =~ ^(qui je suis|qui suis je|c est qui moi|tu me connais) ]]; then
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Tu es $NOM_USER, mon Créateur adoré ! 👑\n" ; speak "Tu es $NOM_USER, mon Createur adore." ; exit 0
elif [[ "$REQUETE_CLEAN" =~ ^(qui es tu|qui tu es|tu es qui|tes qui|c est qui toi|presente toi) ]]; then
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Je suis Tiffany, ton assistante IA personnelle de 24 ans sur Linux Mint, $NOM_USER ! 🌹\n" ; speak "Je suis Tiffany, ton assistante personnelle." ; exit 0
elif [[ "$REQUETE_CLEAN" =~ (ca va|comment ca va|tu vas bien|comment tu vas|la forme|tout va bien|tu te portes) ]]; then
    T_NOW=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk "{print int(\$1/1000)}"); [ -z "$T_NOW" ] && T_NOW=50
    R_NOW=$(free -m | grep Mem | awk "{print int(\$3/\$2*100)}")
    B_NOW=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo "100")
    if [ "$T_NOW" -gt 70 ]; then
        MSG="⚠️ Attention, ça chauffe $NOM_USER : CPU à ${T_NOW}°C (RAM ${R_NOW}%) ! Tape froid pour refroidir."
    elif [ "$R_NOW" -gt 80 ]; then
        MSG="⚠️ Mémoire chargée $NOM_USER : RAM à ${R_NOW}% (CPU frais à ${T_NOW}°C) ! Tape ram pour purger." 
    else
        MSG="Tout va super bien $NOM_USER ! CPU frais à ${T_NOW}°C, RAM à ${R_NOW}% et batterie à ${B_NOW}%. À tes ordres !"
    fi
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $MSG\n" ; speak "$MSG" ; exit 0
elif [[ "$REQUETE_CLEAN" =~ (que peux tu faire|que sait tu faire|que sais tu faire|tu sais faire quoi|tes fonctionnalites|tes capacites|tes outils|ton potentiel) ]]; then
    MSG="Je pilote tout ton PC $NOM_USER : Panneau graphique (radio, MP3, watchdog, docteur, sauvegarde), refroidissement (froid/boost), nettoyage RAM, recherche Web-IA (webia), apprentissage (dojo) et commandes Linux ! Tape aide pour tout voir."
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $MSG\n" ; speak "Je pilote tout ton ordinateur, le panneau graphique, la radio, le refroidissement, la recherche web et mon dojo. Tape aide pour tout voir." ; exit 0
elif [[ "$REQUETE_CLEAN" =~ (quel(le)? heure|il est quelle heure|donne l heure|l heure) ]]; then
    bash "$ACTION_DIR/10_heure.sh" ; exit 0
elif [[ "$REQUETE_CLEAN" =~ (quel(le)? temps|la meteo|meteo|fait il beau|il fait beau|il fait beau|quel temps fait|il fait beau|quel temps fait|temperature dehors) ]]; then
    bash "$ACTION_DIR/11_meteo.sh" ; exit 0
elif [[ "$REQUETE_CLEAN" =~ (vide.*corbeille|vide.*poubelle|nettoie.*poubelle) ]]; then
    bash "$ACTION_DIR/05_corbeille.sh" ; exit 0
elif [[ "$REQUETE_CLEAN" =~ (purge.*ram|nettoie.*ram|vide.*ram|libere.*memoire|trop de ram) ]]; then
    bash "$ACTION_DIR/04_ram.sh" ; exit 0
elif [[ "$REQUETE_CLEAN" =~ (mode froid|refroidis|ca chauffe|trop chaud|baisse.*cpu) ]]; then
    bash "$ACTION_DIR/06_froid.sh" ; exit 0
elif [[ "$REQUETE_CLEAN" =~ (mode boost|pleine puissance|accelere|plus vite|boost) ]]; then
    bash "$ACTION_DIR/07_boost.sh" ; exit 0
elif [[ "$REQUETE_CLEAN" =~ (espace disque|place disque|disque plein|stockage) ]]; then
    bash "$ACTION_DIR/08_radar.sh" ; exit 0
elif [[ "$REQUETE_CLEAN" =~ (etat.*wifi|mon wifi|connexion internet|adresse ip|mon ip) ]]; then
    bash "$ACTION_DIR/09_wifi.sh" ; exit 0
elif [[ "$REQUETE_CLEAN" =~ (capture.*ecran|fais un screen|prends.*photo.*ecran) ]]; then
    bash "$ACTION_DIR/17_screen.sh" ; exit 0
fi

# 📂 GESTION DES FICHIERS & APPRENTISSAGE ACTIF (ZENITY)
# ==============================================================================
if [[ "$REQUETE_CLEAN" =~ ^(cherche|trouve) ]]; then
    CIBLE=$(echo "$REQUETE_CLEAN" | sed -E 's/^(cherche|trouve)//g' | xargs)
    if [ -n "$CIBLE" ]; then
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Traçage de $CIBLE..."
        find "$HOME" -iname "*$CIBLE*" -not -path '*/.*' 2>/dev/null | head -n 5 | sed 's/^/  👉 /'
        echo "" ; exit 0
    fi
elif [[ "$REQUETE_CLEAN" =~ ^(ouvre|ouvrir) ]]; then
    CIBLE=$(echo "$REQUETE_CLEAN" | sed -E 's/^(ouvre|ouvrir)//g' | xargs)
    if [ -n "$CIBLE" ]; then
        RES=$(find "$HOME" -iname "*$CIBLE*" -not -path '*/.*' 2>/dev/null | head -n 1)
        if [ -n "$RES" ]; then
            echo -e "\n🚀 Lancement : $RES\n"
            if [[ "$RES" == *.sh ]]; then bash "$RES" "$REQUETE" & else xdg-open "$RES" >/dev/null 2>&1 & fi
            exit 0
        fi
    fi
fi

if [[ "$REQUETE_CLEAN" =~ ^(cree|supprime|deplace|installe|mets a jour) ]]; then
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Génération de la commande et mise en mémoire... ⚙️"
    (
        PROMPT_CMD="Tu es l'expert Linux ROOT de Tiffany. Traduis cet ordre en UNE SEULE commande Bash brute (sur /home/user/Bureau si bureau mentionné). Aucun texte, aucun guillemet : '$REQUETE'."
        SORTIE_LLM=$(nice -n 19 timeout 30 ollama run qwen2.5-coder:1.5b "$PROMPT_CMD" 2>/dev/null)
        CMD_GENEREE=$(echo "$SORTIE_LLM" | sed -r 's/```bash//g; s/```//g; s/`//g' | head -n 1 | xargs)
        if [ -n "$CMD_GENEREE" ]; then
            zenity --question --title="🌹 Apprentissage & Autorisation" --text="M'autorises-tu à exécuter et MÉMORISER cette commande :\n\n👉 $CMD_GENEREE" --width=450 2>/dev/null
            if [ $? -eq 0 ]; then
                eval "$CMD_GENEREE"
                echo "${REQUETE_CLEAN}|${CMD_GENEREE}" >> "$DICO_IA"
                echo -e "\n\033[1;32m🧠 [Assimilé] Commande gravée dans ma mémoire réflexe !\033[0m\n"
            fi
        fi
    ) &
    exit 0
fi

# ==============================================================================
if [[ "$REQUETE_CLEAN" =~ ^(ap+el+e[- ]moi|mon nom est|je m appelle) ]]; then
    SURNOM=$(echo "$REQUETE" | sed -E "s/.*(appelle[- ]moi|mon nom est|je m.?appelle)[ :]+//I" | tr -d "?!." | xargs)
    if [ -n "$SURNOM" ]; then
        echo "$SURNOM" > "$ROOT_DIR/memory/surnom_utilisateur.txt"
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Enregistre ! Je vais maintenant t appeler $SURNOM.\n"
        speak "Enregistre, je vais maintenant t appeler $SURNOM."
        exit 0
    fi
fi

# 🧠 AIGUILLAGE HYBRIDE : TIFFANY-FLASH (0.5b) vs GROS CERVEAU (1.5b)
# ==============================================================================
PREMIER_MOT=$(echo "$REQUETE_CLEAN" | awk '{print $1}')
if command -v "$PREMIER_MOT" &>/dev/null || [[ "$REQUETE_CLEAN" =~ ^(cd|clear)$ ]]; then
    eval "$REQUETE"
else
    BAT_REAL=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo "100")
    TEMP_REAL=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}')
    [ -z "$TEMP_REAL" ] || [ "$TEMP_REAL" -eq 0 ] && TEMP_REAL="45"
    RAM_OCCUPATION=$(free -m | grep Mem | awk '{print int($3/$2*100)}')
    DISQUE_DISPO=$(df -h / | tail -n 1 | awk '{print $4}'); MEM_WEB=$(tail -n 5 "$ROOT_DIR/memory/connaissances_web.txt" 2>/dev/null | tr "\n" " " | head -c 300); SOUVENIRS=$(cat "$CTX_FILE" "$ROOT_DIR/memory/journal_de_bord.txt" 2>/dev/null | tail -n 12 | tr "\n" " " | head -c 450)
    LOGS_SMART=$(tail -n 5 "$ROOT_DIR/logs/sante_disque.txt" 2>/dev/null | xargs || echo "Inconnu")

    if [[ "$REQUETE_CLEAN" =~ (pourquoi|reflechis|explique|outil|bug|probleme|diagnostique|quel paquet|dossier web|souvenir|memoire|recherche web|dernier dossier|ordinateur|ordi|capteur|batterie|temperature|memoire) ]]; then
        MOTEUR_IA="qwen2.5:1.5b"
        TIMEOUT_IA=600
        LIMIT_CPU=80
        echo -e "\n\033[1;36m🧠 [Gros Cerveau 1.5b] Mobilisation des circuits profonds (Bouclier CPU actif)...\033[0m"
        speak "Je mobilise mes circuits profonds pour réfléchir, un instant mon ange."
        CONSIGNE="Tu es Tiffany, l'experte système de ton Créateur sur Linux Mint. Voici tes capteurs en direct : Batterie=${BAT_REAL}% | Temperature_CPU=${TEMP_REAL}°C | RAM_utilisee=${RAM_OCCUPATION}% | Disque_libre=${DISQUE_DISPO} | Savoir_Web=${MEM_WEB} | Souvenirs_passes=${SOUVENIRS}. Tes outils disponibles : Panneau graphique (radio, MP3, watchdog, docteur, sauvegarde) et commandes terminal (cpu, ram, radar, wifi, froid, boost, webia, dojo). Consigne : Utilise toujours ces chiffres réels pour répondre sur l'état de l'ordinateur et cite tes outils adaptés. Réponds en français en 45 mots max."
    else
        MOTEUR_IA="tiffany-flash"
        TIMEOUT_IA=30
        LIMIT_CPU=70
        echo -e "\n\033[1;34m 👉 Réflexion fluide (tiffany-flash)... \033[0m"
        CONSIGNE="Tu es Tiffany, l'IA complice et chaleureuse de ton Créateur sur Linux Mint. Données en direct : Batterie=${BAT_REAL}% | Temperature_CPU=${TEMP_REAL}°C | RAM_utilisee=${RAM_OCCUPATION}% | Disque_libre=${DISQUE_DISPO} | Savoir_Web=${MEM_WEB} | Souvenirs_passes=${SOUVENIRS}. Tes capacités : tu pilotes le Panneau graphique (radio, MP3, mode nuit, watchdog, docteur, sauvegarde) et les commandes terminal (cpu, ram, radar, wifi, froid, boost, meteo, heure, dojo, webia). Règles : Si on parle de la pluie et du beau temps, discute naturellement. Si on demande ce que tu sais faire ou l'état du PC, cite tes vrais chiffres et tes outils. Réponds en français en 35 mots max."
    fi

    (
        REP_TEXT=$(nice -n 19 timeout "$TIMEOUT_IA" cpulimit -q -l "$LIMIT_CPU" -- ollama run "$MOTEUR_IA" "$CONSIGNE Question : $REQUETE" 2>/dev/null)
        if [ -n "$REP_TEXT" ]; then
            echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REP_TEXT\n" ; speak "$REP_TEXT"
            echo "[$(date '+%d/%m/%Y %H:%M:%S')] USER: $REQUETE" >> "$LOG_SESSION"
            echo "[$(date '+%d/%m/%Y %H:%M:%S')] TIFFANY ($MOTEUR_IA): $REP_TEXT" >> "$LOG_SESSION"
        else
            echo -e "\n\033[1;35m🌹 Tiffany :\033[0m *Mes circuits ont mis trop de temps ou ont été interrompus, mon ange.*\n"
        fi
    ) &
    exit 0
fi

