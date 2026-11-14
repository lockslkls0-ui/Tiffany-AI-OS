#!/usr/bin/env bash
Q="$1"; RAW="$2"; ROOT_DIR="$HOME/tiffany"; PLUG="$ROOT_DIR/plugins"; ACT="$ROOT_DIR/actions_terminal"
NOM=$(cat "$ROOT_DIR/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")

go() {
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $1\n"
    notify-send -u low -t 3000 -i "dialog-information" "🌹 Tiffany AI-OS" "$1" >/dev/null 2>&1
    pkill -x espeak-ng >/dev/null 2>&1; (espeak-ng -v fr+f5 -s 145 -p 85 "$(echo "$1" | tr -d '🌹🎵📻❄️⚡🚀🩺💾🪟📷✂️🧼🗑️🌙☀️🔊🎙️💻📊🧬📡⏰📂⚙️')" >/dev/null 2>&1) &
    eval "$2" >/dev/null 2>&1 &
    exit 0
}

# ==============================================================================
# 1. RACCOURCIS ULTRA-COURTS SÉCURISÉS (ZÉRO CONFLIT ENTRE OUTILS)
# ==============================================================================
case "$Q" in
    # Multimédia & Radio
    # Groupe 2 : Musique, Rhythmbox, Radio & Téléchargements MP3
    "next"|"skip"|"suivant"|"suivante"|"chanson suivante"|"morceau suivant"|"zappe ce son"|"autre chanson") go "Morceau suivant, $NOM ! ⏭️" "bash '$PLUG/45_morceau_suivant.sh'" ;;
    "pause"|"play"|"reprends"|"lecture"|"mets pause"|"mets sur pause"|"reprends la musique"|"relance la musique") go "Bascule lecture/pause, $NOM ! ⏸️" "bash '$PLUG/44_play_pause.sh'" ;;
    "stop"|"stop musique"|"stop radio"|"coupe la musique"|"arrete la musique"|"eteins la radio"|"coupe la radio") go "Lecture arrêtée, $NOM ! 🤫" "bash '$PLUG/46_couper_radio.sh'" ;;
    "intercepte"|"telecharge cette musique"|"enregistre ce son"|"aspire cette chanson") go "J'intercepte le morceau en MP3, $NOM ! 🎧" "bash '$PLUG/41_intercepter_rhythmbox.sh'" ;;
    "telechargeur mp3"|"extracteur mp3"|"cherche une musique"|"telecharge sur youtube") go "Téléchargeur MP3 intelligent ouvert, $NOM ! 📥" "bash '$PLUG/42_telechargeur_intelligent.sh'" ;;
    # Groupe 1 : Son, Volume & Voix (toutes nuances sans conflit)
    "muet"|"mute"|"coupe le son"|"remets le son"|"active le son"|"mode muet") go "Bascule son système, $NOM ! 🔊" "bash '$PLUG/34_bascule_son.sh'" ;;
    "son +"|"volume +"|"monte le son"|"augmente le son"|"monte le volume"|"augmente le volume"|"plus fort"|"mets plus fort") go "Volume augmenté de 15%, $NOM ! 🔊" "amixer -D pulse sset Master 15%+ 2>/dev/null || amixer sset Master 15%+" ;;
    "son -"|"volume -"|"baisse le son"|"diminue le son"|"baisse le volume"|"diminue le volume"|"moins fort"|"baisse un peu") go "Volume baissé de 15%, $NOM ! 🔉" "amixer -D pulse sset Master 15%- 2>/dev/null || amixer sset Master 15%-" ;;
    "son a fond"|"volume a fond"|"son au max"|"volume au max"|"volume maximum"|"son maximum") go "Volume réglé au maximum (100%), $NOM ! 🔊" "amixer -D pulse sset Master 100% 2>/dev/null || amixer sset Master 100%" ;;
    "son doux"|"volume doux"|"volume bas") go "Volume doux réglé à 30%, $NOM ! 🔉" "amixer -D pulse sset Master 30% 2>/dev/null || amixer sset Master 30%" ;;
    "son moyen"|"volume moyen"|"volume moitie") go "Volume moyen réglé à 50%, $NOM ! 🔊" "amixer -D pulse sset Master 50% 2>/dev/null || amixer sset Master 50%" ;;
    "radio"|"radios"|"zapping")
        URL_R=$(shuf -n 1 "$HOME/.tiffany_radios.txt" "$HOME/.catalogue_geant.txt" 2>/dev/null | head -n 1)
        NOM_R=$(echo "$URL_R" | cut -d'|' -f1); LIEN_R=$(echo "$URL_R" | cut -d'|' -f2)
        go "Je lance ${NOM_R:-la radio} et j'ouvre le panneau radio, $NOM ! 📻" "pkill -9 -x mpv vlc 2>/dev/null; pgrep -x rhythmbox >/dev/null || (rhythmbox >/dev/null 2>&1 & sleep 2); [ -n '$LIEN_R' ] && rhythmbox-client --play-uri='$LIEN_R'; bash '$PLUG/40_gestion_radio.sh'" ;;

    # Interfaces & Dossiers usuels
    "noyau") bash "$ACT/14_noyau.sh" ; exit 0 ;;
    "testia") bash "$ACT/20_test_ia.sh" ; exit 0 ;;
    "menu"|"panneau"|"dashboard") go "J'ouvre mon panneau de commande, $NOM ! 🌹" "bash '$ROOT_DIR/tiffany_menu.sh'" ;;
    "term"|"terminal"|"console"|"bash") go "J'ouvre un terminal, $NOM ! 💻" "gnome-terminal" ;;
    "discussion"|"chat"|"parle") go "J'ouvre notre console de discussion, $NOM ! 💬" "gnome-terminal --title='🌹 Discussion Tiffany' -- bash -c '$ROOT_DIR/tiffany_core.sh'" ;;
    "mes fichiers"|"explorateur"|"nemo") go "J'ouvre tes fichiers personnels, $NOM ! 📂" "nemo '$HOME'" ;;
    "telechargements"|"downloads") go "J'ouvre ton dossier Téléchargements, $NOM ! 📂" "nemo '$HOME/Téléchargements' 2>/dev/null || nemo '$HOME/Downloads'" ;;
    "documents") go "J'ouvre ton dossier Documents, $NOM ! 📂" "nemo '$HOME/Documents'" ;;
    "parametres"|"reglages") go "J'ouvre les paramètres système, $NOM ! ⚙️" "cinnamon-settings 2>/dev/null || gnome-control-center" ;;

    # Vision, Caméra & Écran
    "cam"|"webcam"|"camera"|"photo") go "J'active la webcam OCR, $NOM ! 📷" "bash '$PLUG/36_oeil_webcam.sh'" ;;
    "zone"|"decoupe"|"ocr") go "Sélectionne la zone à lire, $NOM ! ✂️" "bash '$PLUG/29_vision_zone.sh'" ;;
    "nuit"|"mode nuit") go "Filtre de nuit activé, $NOM ! 🌙" "bash '$PLUG/32_filtre_nuit.sh'" ;;
    "jour"|"mode jour") go "Mode jour restauré, $NOM ! ☀️" "bash '$PLUG/33_mode_jour.sh'" ;;
    "lumiere +"|"luminosite +"|"augmente la luminosite"|"plus clair") go "Luminosité augmentée, $NOM ! ☀️" "brightnessctl set +15%" ;;
    "lumiere -"|"luminosite -"|"baisse la luminosite"|"moins clair") go "Luminosité baissée, $NOM ! 🌙" "brightnessctl set 15%-" ;;

    # Voix & Lecture
    "lireweb"|"lis"|"lecture web") bash "$ACT/31_lire_webia.sh" ; exit 0 ;;
    "chut"|"stop voix"|"silence voix") pkill -x espeak-ng >/dev/null 2>&1 ; exit 0 ;;
    "voix") go "Sélecteur de voix ouvert, $NOM ! 🎙️" "bash '$PLUG/35_bascule_voix.sh'" ;;
    "oreille on") go "Oreille vocale permanente activée, $NOM ! 👂" "bash '$PLUG/28_ouie_micro.sh'" ;;
    "oreille off") go "Oreille vocale mise en pause, $NOM ! 🔇" "bash '$PLUG/28b_ouie_off.sh'" ;;

    # Diagnostics séparés clairement (Analyse simple vs Docteur Mistral)
    "analyse"|"materiel"|"bilan"|"etat du pc") bash "$ACT/02_analyse.sh" ; exit 0 ;;
    "docteur"|"mistral"|"audit total"|"diagnostic complet") go "Lancement du Docteur Mistral (Audit Total), $NOM ! 🩺" "bash '$PLUG/16_docteur_mistral.sh'" ;;
    # Groupe 3 : Thermique, CPU, RAM, ZRAM, Watchdog & Docteur (toutes nuances)
    "froid"|"refroidis"|"mode froid"|"ca chauffe"|"trop chaud"|"baisse le cpu") go "Mode Froid activé, $NOM ! ❄️" "bash '$PLUG/11_mode_froid.sh'" ;;
    "boost"|"puissance"|"mode boost"|"pleine puissance"|"accelere le pc") go "Mode Boost Auto activé, $NOM ! ⚡" "bash '$PLUG/12_mode_boost.sh'" ;;
    "watchdog on"|"active sentinelle"|"allume watchdog") go "Sentinelle thermique activée, $NOM ! 🛡️" "bash '$PLUG/13_watchdog_on.sh'" ;;
    "watchdog off"|"coupe sentinelle"|"pause watchdog") go "Sentinelle thermique en pause, $NOM ! ⚠️" "bash '$PLUG/14_watchdog_off.sh'" ;;
    "zram"|"turbo"|"compresse la ram"|"turbo ram") go "Accélération ZRAM vérifiée, $NOM ! 🚀" "bash '$PLUG/25_turbo_zram.sh'" ;;
    "top"|"processus"|"cpu"|"etat cpu") go "Diagnostic CPU en direct, $NOM ! 📊" "bash '$PLUG/20_diagnostic_cpu.sh'" ;;
    "ram"|"memoire"|"etat ram") go "Check-up RAM en direct, $NOM ! 🧠" "bash '$PLUG/21_checkup_ram.sh'" ;;
    "purge ram"|"purge"|"libere la ram"|"nettoie la ram"|"vide la ram") go "Purge éclair RAM et relance Ollama, $NOM ! 🧼" "bash '$PLUG/22_purge_ram.sh'" ;;
    "analyse"|"materiel"|"bilan"|"etat du pc"|"diagnostic rapide") bash "$ACT/02_analyse.sh" ; exit 0 ;;
    "docteur"|"mistral"|"audit total"|"diagnostic complet"|"repare le pc") go "Lancement du Docteur Mistral (Audit Total), $NOM ! 🩺" "bash '$PLUG/16_docteur_mistral.sh'" ;;
    "variante"|"traduction") bash "$ACT/33_variante.sh" ; exit 0 ;;
    "froid_old") go "Mode Froid activé, $NOM ! ❄️" "bash '$PLUG/11_mode_froid.sh'" ;;
    "boost"|"puissance") go "Mode Boost Auto activé, $NOM ! ⚡" "bash '$PLUG/12_mode_boost.sh'" ;;
    "watchdog on") go "Sentinelle thermique activée, $NOM ! 🛡️" "bash '$PLUG/13_watchdog_on.sh'" ;;
    "watchdog off") go "Sentinelle thermique en pause, $NOM ! ⚠️" "bash '$PLUG/14_watchdog_off.sh'" ;;
    "zram"|"turbo") go "Accélération ZRAM vérifiée, $NOM ! 🚀" "bash '$PLUG/25_turbo_zram.sh'" ;;
    "top"|"processus"|"cpu") go "Diagnostic CPU en direct, $NOM ! 📊" "bash '$PLUG/20_diagnostic_cpu.sh'" ;;
    "ram") go "Check-up RAM en direct, $NOM ! 🧠" "bash '$PLUG/21_checkup_ram.sh'" ;;
    "purge ram"|"purge") go "Purge éclair RAM et relance Ollama, $NOM ! 🧼" "bash '$PLUG/22_purge_ram.sh'" ;;
    "reseau"|"wifi"|"ip") go "État réseau et IP affiché, $NOM ! 📡" "bash '$PLUG/24_etat_reseau.sh'" ;;
    "instinct"|"capteurs"|"usb"|"bluetooth") go "Instinct matériel étendu, $NOM ! 🧬" "bash '$PLUG/26_instinct_etendu.sh'" ;;
    "souvenirs"|"memoire") bash "$ACT/32_souvenirs.sh" ; exit 0 ;;

    # Maintenance & Arrêt (Commandes sensibles explicites uniquement)
    "corbeille"|"poubelle") go "Corbeille vidée, $NOM ! 🗑️" "bash '$PLUG/30_vider_corbeille.sh'" ;;
    "nettoie systeme"|"menage systeme") go "Nettoyage système APT lancé, $NOM ! 🧹" "bash '$PLUG/31_nettoyer_systeme.sh'" ;;
    "backup"|"sauvegarde matrice") go "Sauvegarde complète de la matrice lancée, $NOM ! 💾" "bash '$PLUG/15_sauvegarde_matrice.sh'" ;;
    "eteins l ordinateur"|"eteins le pc"|"extinction systeme") go "Extinction propre du Toshiba, à bientôt $NOM ! 💤" "bash '$PLUG/Z99_eteindre_toshiba.sh'" ;;

    # Fenêtres & Souris
    "fenetres"|"range") go "Fenêtres rangées en 50/50, $NOM ! 🪟" "bash '$ACT/30_fenetre.sh' range" ;;
    "bureau") go "Bureau dégagé, $NOM ! 🖥️" "bash '$ACT/30_fenetre.sh' bureau" ;;
    "chrome"|"navigateur"|"internet") go "Ouverture du navigateur, $NOM ! 🌐" "bash '$ACT/30_fenetre.sh' chrome" ;;
    "droite"|"gauche"|"monte"|"descends"|"clic"|"onglet") bash "$ACT/26_pilote.sh" "$Q" ; exit 0 ;;
esac

# ==============================================================================
# 2. VOLUME / LUMINOSITÉ AU POURCENTAGE EXACT & MINUTEUR VOCAL
# ==============================================================================
if [[ "$Q" =~ ^(mets[[:space:]]+le[[:space:]]+)?(son|volume)[[:space:]]+(a[[:space:]]+)?([0-9]+) ]]; then
    VAL=$(echo "$Q" | grep -oE '[0-9]+' | head -n 1)
    [ "$VAL" -gt 100 ] && VAL=100
    go "Volume réglé à ${VAL}%, $NOM ! 🔊" "amixer -D pulse sset Master ${VAL}% 2>/dev/null || amixer sset Master ${VAL}%"
elif [[ "$Q" =~ ^(mets[[:space:]]+la[[:space:]]+)?(luminosite|lumiere)[[:space:]]+(a[[:space:]]+)?([0-9]+) ]]; then
    VAL=$(echo "$Q" | grep -oE '[0-9]+' | head -n 1)
    [ "$VAL" -lt 15 ] && VAL=15 ; [ "$VAL" -gt 100 ] && VAL=100
    go "Luminosité réglée à ${VAL}%, $NOM ! ☀️" "brightnessctl set ${VAL}%"
elif [[ "$Q" =~ ^(minuteur|alarme|rappelle[- ]moi) ]]; then
    bash "$ROOT_DIR/tiffany_outils.sh" "minuteur" "$Q" ; exit 0
fi

# ==============================================================================
# 3. RADIO INTELLIGENTE PAR NOM DE STATION
# ==============================================================================
if [[ "$Q" =~ (radio|station|frequence) ]] && [[ ! "$Q" =~ (coupe|arrete|eteins|stop) ]]; then
    ST_Q=$(echo "$Q" | sed -E 's/.*(allume|mets|lance|ouvre|ecouter|zappe|sur|la|le|de|du|des|une|radio|station)[[:space:]]+//g' | xargs)
    MATCH=$([ -n "$ST_Q" ] && grep -i "$ST_Q" "$HOME/.tiffany_radios.txt" "$HOME/.catalogue_geant.txt" 2>/dev/null | head -n 1 | cut -d':' -f2-)
    [ -z "$MATCH" ] && MATCH=$(shuf -n 1 "$HOME/.tiffany_radios.txt" "$HOME/.catalogue_geant.txt" 2>/dev/null | head -n 1)
    NOM_ST=$(echo "$MATCH" | cut -d'|' -f1); URL_ST=$(echo "$MATCH" | cut -d'|' -f2)
    go "Je lance ${NOM_ST:-la radio} et j'ouvre le panneau radio, $NOM ! 📻" "pkill -9 -x mpv vlc 2>/dev/null; pgrep -x rhythmbox >/dev/null || (rhythmbox >/dev/null 2>&1 & sleep 2); [ -n '$URL_ST' ] && rhythmbox-client --play-uri='$URL_ST'; bash '$PLUG/40_gestion_radio.sh'"
fi

# ==============================================================================
# 4. NUANCES DE PHRASES NATURELLES (SANS AMBIGUÏTÉ)
# ==============================================================================
if [[ "$Q" =~ (intercepte|capture.*morceau|telecharge.*(musique|chanson|son|piste)|aspire.*mp3) ]]; then
    go "J'intercepte le morceau en MP3, $NOM ! 🎵" "bash '$PLUG/41_intercepter_rhythmbox.sh'"
elif [[ "$Q" =~ (telecharge.*youtube|cherche.*mp3|extracteur.*mp3|telecharge.*un.*son) ]]; then
    go "Téléchargeur MP3 intelligent ouvert, $NOM ! 📡" "bash '$PLUG/42_telechargeur_intelligent.sh'"
elif [[ "$Q" =~ (morceau.*suivant|chanson.*suivante|zappe.*(musique|son|chanson)|passe.*(chanson|morceau)|autre.*(chanson|son|musique)) ]]; then
    go "Morceau suivant, $NOM ! ⏭️" "bash '$PLUG/45_morceau_suivant.sh'"
elif [[ "$Q" =~ (mets.*pause|reprends.*musique|relance.*musique|play.*pause) ]]; then
    go "Bascule lecture/pause, $NOM ! ⏸️" "bash '$PLUG/44_play_pause.sh'"
elif [[ "$Q" =~ (coupe.(musique|rhythmbox|radio)|arrete.(musique|rhythmbox|radio)|stop.(musique|radio)) ]]; then
go "Lecture arrêtée, $NOM ! 🤫" "bash '$PLUG/46_couper_radio.sh'"
elif [[ "$Q" =~ (allume.(musique|rhythmbox)|mets.(musique|son|playlist)|lance.(musique|rhythmbox|playlist)|ecouter.*musique) ]]; then
go "J'allume Rhythmbox, $NOM ! 🎵" "bash '$PLUG/43_allumer_rhythmbox.sh'"
elif [[ "$Q" =~ (range.*fenetre|cote a cote|moitie.*ecran|partage.*ecran) ]]; then
go "Fenêtres rangées côte à côte, $NOM ! 🪟" "bash '$ACT/30_fenetre.sh' range"
elif [[ "$Q" =~ (degage.*bureau|montre.*bureau|reduis.*tout) ]]; then
go "Bureau dégagé, $NOM ! 🖥️" "bash '$ACT/30_fenetre.sh' bureau"
elif [[ "$Q" =~ (va sur chrome|passe sur chrome|ouvre.*navigateur|ouvre.*chrome) ]]; then
go "Bascule sur le navigateur, $NOM ! 🌐" "bash '$ACT/30_fenetre.sh' chrome"
elif [[ "$Q" =~ (descend.*page|scroll.*bas) ]]; then bash "$ACT/26_pilote.sh" descends ; exit 0
elif [[ "$Q" =~ (remonte.*page|scroll.*haut) ]]; then bash "$ACT/26_pilote.sh" monte ; exit 0
elif [[ "$Q" =~ (onglet.suivant|change.onglet) ]]; then bash "$ACT/26_pilote.sh" onglet ; exit 0
elif [[ "$Q" =~ (plein ecran|mode cinema) ]]; then bash "$ACT/26_pilote.sh" plein ecran ; exit 0
elif [[ "$Q" =~ (verrouille.(pc|ecran|session)) ]]; then bash "$ACT/26_pilote.sh" verrouille ; exit 0
elif [[ "$Q" =~ (filtre.(nuit|bleu)|protege.*yeux) ]]; then go "Mode nuit activé, $NOM ! 🌙" "bash '$PLUG/32_filtre_nuit.sh'"
elif [[ "$Q" =~ (enleve.*filtre|coupe.*filtre) ]]; then go "Mode jour restauré, $NOM ! ☀️" "bash '$PLUG/33_mode_jour.sh'"
elif [[ "$Q" =~ (coupe.*son|mets.*muet|remet.*son|bascule.*son) ]]; then go "Bascule du son, $NOM ! 🔊" "bash '$PLUG/34_bascule_son.sh'"
elif [[ "$Q" =~ (change.*voix|bascule.*voix|voix douce|voix vive) ]]; then go "Sélecteur de voix ouvert, $NOM ! 🎙️" "bash '$PLUG/35_bascule_voix.sh'"
elif [[ "$Q" =~ (turbo.*ram|compresse.*ram|active.*zram|accelere.*ram) ]]; then go "Accélération ZRAM active, $NOM ! 🚀" "bash '$PLUG/25_turbo_zram.sh'"
elif [[ "$Q" =~ (docteur.*mistral|lance.*docteur|audit.*total) ]]; then go "Docteur Mistral lancé, $NOM ! 🩺" "bash '$PLUG/16_docteur_mistral.sh'"
elif [[ "$Q" =~ (stabilise.*chrome|bride.*chrome) ]]; then go "Chrome stabilisé à 120%, $NOM ! 🛡️" "bash '$PLUG/10_stabiliser_chrome.sh'"
elif [[ "$Q" =~ (sauvegarde.*matrice|archive.*tiffany) ]]; then go "Sauvegarde matrice lancée, $NOM ! 💾" "bash '$PLUG/15_sauvegarde_matrice.sh'"
elif [[ "$Q" =~ (vide.*corbeille|vide.*poubelle) ]]; then go "Corbeille purgée, $NOM ! 🗑️" "bash '$PLUG/30_vider_corbeille.sh'"
fi
exit 1
