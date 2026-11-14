#!/usr/bin/env bash
Q="$1"; RAW="$2"; ROOT_DIR="$HOME/tiffany"; PLUG="$ROOT_DIR/plugins"; ACT="$ROOT_DIR/actions_terminal"
NOM=$(cat "$ROOT_DIR/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")
go() {
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $1\n"
    (espeak-ng -v fr+f5 -s 145 -p 85 "$(echo "$1" | tr -d '🌹🎵📻❄️⚡🚀🩺💾🪟📷✂️🧼🗑️🌙☀️🔊🎙️💻📊')" >/dev/null 2>&1) &
    eval "$2" >/dev/null 2>&1 &
    exit 0
}
case "$Q" in
    "next"|"skip"|"suivant"|"suivante") go "Morceau suivant, $NOM ! ⏭️" "bash '$PLUG/45_morceau_suivant.sh'" ;;
    "pause"|"play"|"reprends"|"lecture") go "Bascule lecture/pause, $NOM ! ⏸️" "bash '$PLUG/44_play_pause.sh'" ;;
    "stop"|"coupe"|"arrete") go "Lecture arrêtée, $NOM ! 🤫" "bash '$PLUG/46_couper_radio.sh'" ;;
    "muet"|"mute"|"silence") go "Bascule son système, $NOM ! 🔊" "bash '$PLUG/34_bascule_son.sh'" ;;
    "musique"|"playlist"|"rhythmbox"|"sons") go "J'allume Rhythmbox, $NOM ! 🎵" "bash '$PLUG/43_allumer_rhythmbox.sh'" ;;
    "radio"|"radios"|"zapping")
        URL_R=$(shuf -n 1 "$HOME/.tiffany_radios.txt" "$HOME/.catalogue_geant.txt" 2>/dev/null | head -n 1)
        NOM_R=$(echo "$URL_R" | cut -d'|' -f1); LIEN_R=$(echo "$URL_R" | cut -d'|' -f2)
        go "Je lance ${NOM_R:-la radio} et j'ouvre le panneau radio, $NOM ! 📻" "pkill -9 -x mpv vlc 2>/dev/null; pgrep -x rhythmbox >/dev/null || (rhythmbox >/dev/null 2>&1 & sleep 2); [ -n '$LIEN_R' ] && rhythmbox-client --play-uri='$LIEN_R'; bash '$PLUG/40_gestion_radio.sh'" ;;
    "menu"|"panneau"|"dashboard") go "J'ouvre mon panneau de commande, $NOM ! 🌹" "bash '$ROOT_DIR/tiffany_menu.sh'" ;;
    "term"|"terminal"|"console"|"bash") go "J'ouvre un terminal, $NOM ! 💻" "gnome-terminal" ;;
    "discussion"|"chat"|"parle") go "J'ouvre notre console de discussion, $NOM ! 💬" "gnome-terminal --title='🌹 Discussion Tiffany' -- bash -c '$ROOT_DIR/tiffany_core.sh'" ;;
    "cam"|"webcam"|"camera"|"photo") go "J'active la webcam OCR, $NOM ! 📷" "bash '$PLUG/36_oeil_webcam.sh'" ;;
    "zone"|"decoupe"|"ocr") go "Sélectionne la zone à lire, $NOM ! ✂️" "bash '$PLUG/29_vision_zone.sh'" ;;
    "nuit"|"sombre") go "Filtre de nuit activé, $NOM ! 🌙" "bash '$PLUG/32_filtre_nuit.sh'" ;;
    "jour"|"clair") go "Mode jour restauré, $NOM ! ☀️" "bash '$PLUG/33_mode_jour.sh'" ;;
    "zram"|"turbo") go "Accélération ZRAM vérifiée, $NOM ! 🚀" "bash '$PLUG/25_turbo_zram.sh'" ;;
    "docteur"|"mistral"|"audit"|"diag"|"diagnostic") go "Lancement du Docteur Mistral, $NOM ! 🩺" "bash '$PLUG/16_docteur_mistral.sh'" ;;
    "backup"|"sauvegarde"|"sauve") go "Sauvegarde matrice lancée, $NOM ! 💾" "bash '$PLUG/15_sauvegarde_matrice.sh'" ;;
    "top"|"processus") go "Diagnostic CPU en direct, $NOM ! 📊" "bash '$PLUG/20_diagnostic_cpu.sh'" ;;
    "instinct"|"capteurs"|"usb"|"bluetooth") go "Instinct matériel étendu, $NOM ! 🧬" "bash '$PLUG/26_instinct_etendu.sh'" ;;
    "fenetres"|"range") go "Fenêtres rangées en 50/50, $NOM ! 🪟" "bash '$ACT/30_fenetre.sh' range" ;;
    "bureau") go "Bureau dégagé, $NOM ! 🖥️" "bash '$ACT/30_fenetre.sh' bureau" ;;
    "chrome"|"navigateur"|"internet"|"web") go "Ouverture du navigateur, $NOM ! 🌐" "bash '$ACT/30_fenetre.sh' chrome" ;;
    "droite"|"gauche"|"monte"|"descends"|"clic"|"onglet") bash "$ACT/26_pilote.sh" "$Q" ; exit 0 ;;
esac
if [[ "$Q" =~ (radio|station|frequence|ecouter) ]] && [[ ! "$Q" =~ (coupe|arrete|eteins|stop) ]]; then
    ST_Q=$(echo "$Q" | sed -E 's/.*(allume|mets|lance|ouvre|ecouter|zappe|sur|la|le|de|du|des|une|radio|station)[[:space:]]+//g' | xargs)
    MATCH=$([ -n "$ST_Q" ] && grep -i "$ST_Q" "$HOME/.tiffany_radios.txt" "$HOME/.catalogue_geant.txt" 2>/dev/null | head -n 1 | cut -d':' -f2-)
    [ -z "$MATCH" ] && MATCH=$(shuf -n 1 "$HOME/.tiffany_radios.txt" "$HOME/.catalogue_geant.txt" 2>/dev/null | head -n 1)
    NOM_ST=$(echo "$MATCH" | cut -d'|' -f1); URL_ST=$(echo "$MATCH" | cut -d'|' -f2)
    go "Je lance ${NOM_ST:-la radio} et j'ouvre le panneau radio, $NOM ! 📻" "pkill -9 -x mpv vlc 2>/dev/null; pgrep -x rhythmbox >/dev/null || (rhythmbox >/dev/null 2>&1 & sleep 2); [ -n '$URL_ST' ] && rhythmbox-client --play-uri='$URL_ST'; bash '$PLUG/40_gestion_radio.sh'"
fi
if [[ "$Q" =~ (intercepte|capture.*morceau|telecharge.*(musique|chanson|son|piste)|aspire.*mp3) ]]; then
    go "J'intercepte le morceau en MP3, $NOM ! 🎵" "bash '$PLUG/41_intercepter_rhythmbox.sh'"
elif [[ "$Q" =~ (telecharge.*youtube|cherche.*mp3|extracteur.*mp3|telecharge.*un.*son) ]]; then
    go "Téléchargeur MP3 intelligent ouvert, $NOM ! 📡" "bash '$PLUG/42_telechargeur_intelligent.sh'"
elif [[ "$Q" =~ (suivant|zappe.*(musique|son|chanson|piste)|passe.*(chanson|morceau)|autre.*(chanson|son|musique)|change.*(musique|chanson|son)) ]]; then
    go "Morceau suivant, $NOM ! ⏭️" "bash '$PLUG/45_morceau_suivant.sh'"
elif [[ "$Q" =~ (mets.*pause|reprends.*musique|relance.*musique|play.*pause) ]]; then
    go "Bascule lecture/pause, $NOM ! ⏸️" "bash '$PLUG/44_play_pause.sh'"
elif [[ "$Q" =~ (coupe.*(musique|rhythmbox|radio)|arrete.*(musique|rhythmbox|radio)|stop.*(musique|radio)) ]]; then
    go "Lecture arrêtée, $NOM ! 🤫" "bash '$PLUG/46_couper_radio.sh'"
elif [[ "$Q" =~ (allume.*(musique|rhythmbox)|mets.*(musique|son|playlist)|lance.*(musique|rhythmbox|playlist)|ecouter.*musique) ]]; then
    go "J'allume Rhythmbox, $NOM ! 🎵" "bash '$PLUG/43_allumer_rhythmbox.sh'"
elif [[ "$Q" =~ (range.*fenetre|cote a cote|moitie.*ecran|partage.*ecran) ]]; then
    go "Fenêtres rangées côte à côte, $NOM ! 🪟" "bash '$ACT/30_fenetre.sh' range"
elif [[ "$Q" =~ (degage.*bureau|montre.*bureau|reduis.*tout) ]]; then
    go "Bureau dégagé, $NOM ! 🖥️" "bash '$ACT/30_fenetre.sh' bureau"
elif [[ "$Q" =~ (va sur chrome|passe sur chrome|ouvre.*navigateur|ouvre.*chrome) ]]; then
    go "Bascule sur le navigateur, $NOM ! 🌐" "bash '$ACT/30_fenetre.sh' chrome"
elif [[ "$Q" =~ (descend|scroll.*bas) ]]; then bash "$ACT/26_pilote.sh" descends ; exit 0
elif [[ "$Q" =~ (remonte|scroll.*haut) ]]; then bash "$ACT/26_pilote.sh" monte ; exit 0
elif [[ "$Q" =~ (onglet.*suivant|change.*onglet) ]]; then bash "$ACT/26_pilote.sh" onglet ; exit 0
elif [[ "$Q" =~ (plein ecran|mode cinema) ]]; then bash "$ACT/26_pilote.sh" plein ecran ; exit 0
elif [[ "$Q" =~ (verrouille.*(pc|ecran)) ]]; then bash "$ACT/26_pilote.sh" verrouille ; exit 0
elif [[ "$Q" =~ (mode nuit|filtre.*(nuit|bleu)|protege.*yeux) ]]; then go "Mode nuit activé, $NOM ! 🌙" "bash '$PLUG/32_filtre_nuit.sh'"
elif [[ "$Q" =~ (mode jour|enleve.*filtre|coupe.*filtre) ]]; then go "Mode jour restauré, $NOM ! ☀️" "bash '$PLUG/33_mode_jour.sh'"
elif [[ "$Q" =~ (coupe.*son|mets.*muet|remet.*son|bascule.*son) ]]; then go "Bascule du son, $NOM ! 🔊" "bash '$PLUG/34_bascule_son.sh'"
elif [[ "$Q" =~ (change.*voix|bascule.*voix|voix douce|voix vive) ]]; then go "Sélecteur de voix ouvert, $NOM ! 🎙️" "bash '$PLUG/35_bascule_voix.sh'"
elif [[ "$Q" =~ (turbo.*ram|compresse.*ram|active.*zram|accelere.*ram) ]]; then go "Accélération ZRAM active, $NOM ! 🚀" "bash '$PLUG/25_turbo_zram.sh'"
elif [[ "$Q" =~ (docteur|mistral|audit.*total|repare.*pc) ]]; then go "Docteur Mistral lancé, $NOM ! 🩺" "bash '$PLUG/16_docteur_mistral.sh'"
elif [[ "$Q" =~ (stabilise.*chrome|bride.*chrome) ]]; then go "Chrome stabilisé à 120%, $NOM ! 🛡️" "bash '$PLUG/10_stabiliser_chrome.sh'"
elif [[ "$Q" =~ (sauvegarde.*matrice|sauvegarde.*tout|archive.*tiffany) ]]; then go "Sauvegarde matrice lancée, $NOM ! 💾" "bash '$PLUG/15_sauvegarde_matrice.sh'"
elif [[ "$Q" =~ (eteins.*(pc|ordinateur|toshiba)|extinction) ]]; then go "Extinction propre du Toshiba, $NOM ! 💤" "bash '$PLUG/Z99_eteindre_toshiba.sh'"
fi
exit 1
