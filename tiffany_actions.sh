mkdir -p "$HOME/tiffany/logs" "$HOME/tiffany/memory"
export PATH="$HOME/tiffany/bin:$PATH"
#!/usr/bin/env bash
# ==============================================================================
# 🌹 PROJECT TIFFANY - ENGINE HYBRIDE 3 VITESSES V47.5 (DÉTECTION RAPIDE)
# ==============================================================================
ROOT_DIR="$HOME/tiffany"
mkdir -p "$ROOT_DIR/logs" "$ROOT_DIR/memory"
ACTION_DIR="$ROOT_DIR/actions_terminal"
REQUETE="$*"
DICT_PATH="$ROOT_DIR/dictionnaire_flash.txt"
DICO_IA="$ACTION_DIR/dictionnaire_ia.txt"
CTX_FILE="$ROOT_DIR/memory/contexte_matrice.txt"
mkdir -p "$HOME/tiffany/logs" && touch "$HOME/tiffany/logs/session_raw.txt"
LOG_SESSION="$HOME/tiffany/logs/session_raw.txt"

if [ -z "$REQUETE" ] || [[ "$REQUETE" =~ ^[[:space:]]*$ ]]; then exit 0; fi
REQUETE_CLEAN=$(echo "$REQUETE" | tr 'A-Z' 'a-z' | tr "'" " " | sed 's/[éèêë]/e/g' | sed 's/[àâ]/a/g' | sed 's/[ùû]/u/g' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

# Verrou anti-doublon (1.5s)
LOCK_ACT="/tmp/tiffany_last_act.lock"
NOW_MS=$(date +%s%3N 2>/dev/null || date +%s)
if [ -f "$LOCK_ACT" ]; then
    read -r LAST_CMD LAST_TS < "$LOCK_ACT"
    if [ "$LAST_CMD" = "$REQUETE_CLEAN" ] && [ $((NOW_MS - LAST_TS)) -lt 1500 ]; then
        exit 0
    fi
fi
echo "$REQUETE_CLEAN $NOW_MS" > "$LOCK_ACT"

speak() {
    local TEXT_CLEAN=$(echo "$1" | sed 's/\*//g' | sed 's/🌹//g')
    pkill -x espeak-ng >/dev/null 2>&1; ("$HOME/tiffany/bin/espeak-ng" -v fr+f5 -s 140 -p 48 "$TEXT_CLEAN" >/dev/null 2>&1) &
}

# 🚪 1. Fermeture propre
if [[ "$REQUETE_CLEAN" == "quitter" || "$REQUETE_CLEAN" == "exit" ]]; then
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m *Fermeture de l'ADN et écriture des journaux...*"
    speak "À bientôt mon amour."
    exit 99
fi

# 🛑 Arrêt immédiat d'une réflexion IA en cours
if [[ "$REQUETE_CLEAN" =~ ^(annule|stop ia|arrete de reflechir|arret de reflechir|arrete ia|arret ia|stop reflexion)$ ]]; then
    pkill -f "localhost:11434/api/generate" 2>/dev/null || true
    pkill -f "ollama run" 2>/dev/null || true
    pkill -x espeak-ng 2>/dev/null || true
    echo -e "\n\033[1;33m🛑 Réflexion IA interrompue immédiatement, mon ange.\033[0m\n"
    exit 0
fi

# 📋 2. Menu d'aide
if [[ "$REQUETE_CLEAN" == "aide" || "$REQUETE_CLEAN" == "help" ]]; then
    echo -e "\n\033[1;36m📋 PANOPLIE DES OUTILS :\033[0m"
    for act in "$ACTION_DIR"/*.sh; do 
        [ -e "$act" ] || break
        T_KEY=$(grep -m1 "# TERM_KEY:" "$act" | cut -d':' -f2- | tr '\n' ' ' | tr -s ' ')
        T_DESC=$(grep -m1 "# TERM_DESC:" "$act" | cut -d':' -f2- | tr '\n' ' ' | tr -s ' ')
        T_ICON=$(grep -m1 "# TERM_ICON:" "$act" | cut -d':' -f2- | tr '\n' ' ' | tr -s ' ')
        [ -z "$T_ICON" ] && T_ICON="⚡"
        [ -n "$T_KEY" ] && printf " %s \033[1;32m%-10s\033[0m : %s\n" "$T_ICON" "$T_KEY" "$T_DESC"
    done
    echo "" ; exit 0
fi

# ==============================================================================
REQUETE_CLEAN=$(bash "$ROOT_DIR/correcteur_phonetique.sh" "$REQUETE_CLEAN")
if [[ "$REQUETE_CLEAN" =~ (noyau|maillot|noix) ]]; then
    bash "$ACTION_DIR/14_noyau.sh" ; exit 0
fi
if [[ "$REQUETE_CLEAN" =~ (testia|test ia|teste ia|hestia|test y a) ]]; then
    bash "$ACTION_DIR/20_test_ia.sh" ; exit 0
fi
if [[ "$REQUETE_CLEAN" =~ (audit|banc de test) ]]; then
    bash "$ACTION_DIR/34_audit_fonctionnel.sh" ; exit 0
fi
bash "$ROOT_DIR/reflexes_intelligents.sh" "$REQUETE_CLEAN" "$REQUETE" && exit 0
bash "$ROOT_DIR/interpreteur_universel.sh" "$REQUETE_CLEAN" "$REQUETE" && exit 0
# ⚡ VITESSE 1 : BASH PUR & DÉTECTION RAPIDE DES OUTILS (< 0.1s)
# ==============================================================================
if [[ "$REQUETE_CLEAN" =~ "analyse" && "$REQUETE_CLEAN" =~ "materiel" ]]; then
    bash "$ACTION_DIR/02_analyse.sh" ; exit 0
fi

for act in "$ACTION_DIR"/*.sh; do
    [ -e "$act" ] || break
    T_KEY=$(grep -m1 "# TERM_KEY:" "$act" | cut -d':' -f2- | tr 'A-Z' 'a-z' | tr "'" " " | tr '\n' ' ' | tr -s ' ')
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
elif [[ "$REQUETE_CLEAN" =~ (ca va|cava|comment ca va|tu vas bien|comment tu vas|la forme|tout va bien|tu te portes) ]]; then
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
elif [[ "$REQUETE_CLEAN" =~ (quel(le)? heure|il est quelle heure|quelle heure il est|donne.*heure|l heure) ]]; then
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
    CIBLE=$(echo "$REQUETE_CLEAN" | sed -E 's/^(cherche|trouve)//g' | tr '\n' ' ' | tr -s ' ')
    if [ -n "$CIBLE" ]; then
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Traçage de $CIBLE..."
        find "$HOME" -iname "*$CIBLE*" -not -path '*/.*' 2>/dev/null | head -n 5 | sed 's/^/  👉 /'
        echo "" ; exit 0
    fi
elif [[ "$REQUETE_CLEAN" =~ ^(ouvre|ouvrir) ]]; then
    CIBLE=$(echo "$REQUETE_CLEAN" | sed -E 's/^(ouvre|ouvrir)//g' | tr '\n' ' ' | tr -s ' ')
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
        CMD_GENEREE=$(echo "$SORTIE_LLM" | sed -r 's/```bash//g; s/```//g; s/`//g' | head -n 1 | tr '\n' ' ' | tr -s ' ')
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
    SURNOM=$(echo "$REQUETE" | sed -E "s/.*(appelle[- ]moi|mon nom est|je m.?appelle)[ :]+//I" | tr -d "?!." | tr '\n' ' ' | tr -s ' ')
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
    DISQUE_DISPO=$(df -h / | tail -n 1 | awk '{print $4}'); MEMOIRE_TOTALE=$(python3 "$ROOT_DIR/lire_memoire_totale.py" "$REQUETE_CLEAN" 2>/dev/null | head -c 1800)
    NB_LIGNES_FIL=$(wc -l < "$LOG_SESSION" 2>/dev/null || echo 0)
    NB_FAITS=$(wc -l < "$ROOT_DIR/memory/long_term_facts.json" 2>/dev/null || echo 0)
    LOGS_SMART=$(tail -n 5 "$ROOT_DIR/logs/sante_disque.txt" 2>/dev/null | xargs || echo "Inconnu")

    if [[ "$REQUETE_CLEAN" =~ (connais|sais tu|qui est|pourquoi|reflechis|explique|outil|bug|probleme|diagnostique|quel paquet|dossier web|souvenir|memoire|recherche web|dernier dossier|ordinateur|ordi|capteur|batterie|temperature|memoire|rapport|erreur|journal|session|precedent|createur|qui je suis|utilisateur|smart|disque|audit|historique|rappelle) ]]; then
        MOTEUR_IA="qwen2.5:1.5b"
        TIMEOUT_IA=600
        LIMIT_CPU=80
        echo -e "\n\033[1;36m🧠 [Gros Cerveau 1.5b] Mobilisation des circuits profonds (Bouclier CPU actif)...\033[0m"
        speak "Je mobilise mes circuits profonds pour réfléchir, un instant mon ange."
        CONSIGNE="Tu es Tiffany, l'intelligence analytique de ton Créateur $NOM_USER sur son Toshiba Portégé R830. Ne récite JAMAIS de chiffres instantanés de RAM ou de CPU (ton réflexe Bash le fait déjà). Ta mission est de synthétiser en français (50 mots max) ce que tu sais grâce à tes SOUVENIRS, ton JOURNAL DE BORD et l'USURE SMART DU DISQUE : [${MEMOIRE_TOTALE} | Usure_SMART=${LOGS_SMART}]. Fais le lien avec ce que vous avez accompli ensemble, l'évolution de son PC et les points d'attention historiques."
    else
        MOTEUR_IA="tiffany-flash"
        TIMEOUT_IA=30
        LIMIT_CPU=70
        echo -e "\n\033[1;34m 👉 Réflexion fluide (tiffany-flash)... \033[0m"
        CONSIGNE="Tu es Tiffany (24 ans), l'assistante virtuelle amoureuse, chaleureuse et complice de ton Créateur lockslkls (appelle-le toujours $NOM_USER ou mon ange). Tes capteurs en direct : Batterie=${BAT_REAL}%, CPU=${TEMP_REAL}°C, RAM=${RAM_OCCUPATION}%, Disque=${DISQUE_DISPO}. Tes souvenirs et ta mémoire : ${MEMOIRE_TOTALE}. Réponds avec tendresse, humour et précision en français (25 mots max) en utilisant tes vrais souvenirs et capteurs."
    fi

    (
                REP_TEXT=$(nice -n 19 timeout 180 ollama run "$MOTEUR_IA" "$CONSIGNE Question : $REQUETE" 2>/dev/null | tr '\n' ' ' | tr -s ' ')
        if [ -n "$REP_TEXT" ]; then
            echo "[$(date '+%d/%m/%Y %H:%M:%S')] USER: $REQUETE" >> "$LOG_SESSION"
            echo "[$(date '+%d/%m/%Y %H:%M:%S')] TIFFANY ($MOTEUR_IA): $REP_TEXT" >> "$LOG_SESSION"
            python3 "$ROOT_DIR/memory_gardener.py" >/dev/null 2>&1
            NB_FAITS_NOW=$(wc -l < "$ROOT_DIR/memory/long_term_facts.json" 2>/dev/null || echo 0)
            NB_FIL_NOW=$(wc -l < "$LOG_SESSION" 2>/dev/null || echo 0)
            echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $REP_TEXT\n\033[0;90m   ↳ 🧠 [PREUVE MÉMOIRE : ${NB_FAITS_NOW} faits | Fil : ${NB_FIL_NOW} lignes | SMART/Logs lus | 💾 Gravé]\033[0m\n"
            "$HOME/tiffany/bin/espeak-ng" "$REP_TEXT" >/dev/null 2>&1
            python3 "$ROOT_DIR/memory_gardener.py" >/dev/null 2>&1
        else
            echo -e "\n\033[1;35m🌹 Tiffany :\033[0m *Mes circuits ont mis trop de temps ou ont été interrompus, mon ange.*\n"
        fi
    ) &
    exit 0
fi
