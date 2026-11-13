#!/usr/bin/env bash
Q="$1"
RAW="$2"
ROOT_DIR="$HOME/tiffany"
PLUG="$ROOT_DIR/plugins"
ACT="$ROOT_DIR/actions_terminal"
NOM=$(cat "$ROOT_DIR/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")

go() {
    local MSG="$1"
    local CMD="$2"
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $MSG\n"
    (espeak-ng -v fr+f5 -s 145 -p 85 "$(echo "$MSG" | tr -d '🌹🎵📻❄️⚡🚀🩺💾🪟📷✂️🧼🗑️🌙☀️🔊🎙️')" >/dev/null 2>&1) &
    eval "$CMD" >/dev/null 2>&1 &
    exit 0
}

# --- 🎵 MUSIQUE & RHYTHMBOX (Toutes nuances) ---
if [[ "$Q" =~ (intercepte|capture.*morceau|telecharge.*(musique|chanson|son|piste)|aspire.*mp3) ]]; then
    go "J'intercepte et télécharge le morceau en MP3, $NOM ! 🎵" "bash '$PLUG/41_intercepter_rhythmbox.sh'"
elif [[ "$Q" =~ (telecharge.*youtube|cherche.*mp3|extracteur.*mp3|telechargeur.*intelligent) ]]; then
    go "J'ouvre le téléchargeur MP3 intelligent, $NOM ! 📡" "bash '$PLUG/42_telechargeur_intelligent.sh'"
elif [[ "$Q" =~ (suivant|zappe.*(musique|son|chanson|piste)|passe.*chanson|morceau.*suivant|autre.*chanson) ]]; then
    go "Morceau suivant, $NOM ! ⏭️" "bash '$PLUG/45_morceau_suivant.sh'"
elif [[ "$Q" =~ (pause|reprends.*musique|relance.*musique|play.*pause|mets.*pause) ]]; then
    go "Bascule lecture/pause sur Rhythmbox, $NOM ! ⏸️" "bash '$PLUG/44_play_pause.sh'"
elif [[ "$Q" =~ (coupe.*(musique|rhythmbox)|arrete.*(musique|rhythmbox)|stop.*musique) ]]; then
    go "J'arrête la musique et je vide la file, $NOM ! 🤫" "bash '$PLUG/46_couper_radio.sh'"
elif [[ "$Q" =~ (allume.*(musique|rhythmbox)|mets.*(musique|son|playlist)|lance.*(musique|rhythmbox|playlist)|fais.*tourner.*musique|ecouter.*musique) ]]; then
    go "J'allume Rhythmbox et je lance ta playlist aléatoire, $NOM ! 🎵" "bash '$PLUG/43_allumer_rhythmbox.sh'"

# --- 📻 RADIO & ZAPPING (Toutes nuances) ---
elif [[ "$Q" =~ (coupe.*radio|arrete.*radio|eteins.*radio|stop.*radio) ]]; then
    go "Je coupe la radio tout de suite, $NOM ! 🤫" "bash '$PLUG/46_couper_radio.sh'"
elif [[ "$Q" =~ (allume.*radio|mets.*radio|lance.*radio|ouvre.*radio|ecouter.*radio|zappe.*radio|station.*radio) ]]; then
    go "J'allume ton panneau radio et zapping mondial, $NOM ! 📻" "bash '$PLUG/40_gestion_radio.sh'"

# --- 🪟 FENÊTRES, SOURIS & ÉCRAN (Toutes nuances) ---
elif [[ "$Q" =~ (range.*fenetre|cote a cote|moitie.*ecran|partage.*ecran|organise.*fenetre|aligne.*fenetre) ]]; then
    go "Je range tes deux fenêtres côte à côte en 50/50, $NOM ! 🪟" "bash '$ACT/30_fenetre.sh' range"
elif [[ "$Q" =~ (degage.*bureau|montre.*bureau|reduis.*tout|cache.*fenetre|affiche.*bureau) ]]; then
    go "Je dégage ton bureau, $NOM ! 🖥️" "bash '$ACT/30_fenetre.sh' bureau"
elif [[ "$Q" =~ (va sur chrome|passe sur chrome|ouvre.*navigateur|va sur internet|ouvre.*chrome) ]]; then
    go "Je bascule sur ton navigateur, $NOM ! 🌐" "bash '$ACT/30_fenetre.sh' chrome"
elif [[ "$Q" =~ (descend|defil.*bas|scroll.*bas|page.*bas) ]]; then
    bash "$ACT/26_pilote.sh" descends ; exit 0
elif [[ "$Q" =~ (remonte|defil.*haut|scroll.*haut|page.*haut) ]]; then
    bash "$ACT/26_pilote.sh" monte ; exit 0
elif [[ "$Q" =~ (onglet.*suivant|change.*onglet|passe.*onglet) ]]; then
    bash "$ACT/26_pilote.sh" onglet ; exit 0
elif [[ "$Q" =~ (ferme.*onglet) ]]; then
    bash "$ACT/26_pilote.sh" ferme onglet ; exit 0
elif [[ "$Q" =~ (plein ecran|agrandis.*ecran|mode cinema) ]]; then
    bash "$ACT/26_pilote.sh" plein ecran ; exit 0
elif [[ "$Q" =~ (double clic) ]]; then
    bash "$ACT/26_pilote.sh" double clic ; exit 0
elif [[ "$Q" =~ (clic droit) ]]; then
    bash "$ACT/26_pilote.sh" clic droit ; exit 0
elif [[ "$Q" =~ ^(clique|fais un clic|clic)$ ]]; then
    bash "$ACT/26_pilote.sh" clic ; exit 0
elif [[ "$Q" =~ (verrouille.*(pc|ecran|session)|mets.*veille) ]]; then
    bash "$ACT/26_pilote.sh" verrouille ; exit 0

# --- 👁️ VISION ZONE & WEBCAM (Toutes nuances) ---
elif [[ "$Q" =~ (vision.*zone|selectionne.*zone|copie.*zone|capture.*zone|lis.*zone|decoupe.*ecran) ]]; then
    go "Sélectionne la zone à lire avec ta souris, $NOM ! ✂️" "bash '$PLUG/29_vision_zone.sh'"
elif [[ "$Q" =~ (webcam|camera|lis.*(feuille|document|papier)|prends.*photo|regarde.*moi) ]]; then
    go "J'active l'œil de la webcam pour lire devant l'objectif, $NOM ! 📷" "bash '$PLUG/36_oeil_webcam.sh'"

# --- 🌙 ÉCRAN, NUIT & AUDIO (Toutes nuances) ---
elif [[ "$Q" =~ (mode nuit|filtre.*(nuit|bleu|chaud)|protege.*yeux|fatigue.*yeux) ]]; then
    go "J'active le filtre de nuit doux pour tes yeux, $NOM ! 🌙" "bash '$PLUG/32_filtre_nuit.sh'"
elif [[ "$Q" =~ (mode jour|enleve.*filtre|coupe.*filtre|lumiere.*normale|clarte.*normale) ]]; then
    go "Je restaure l'affichage normal de jour, $NOM ! ☀️" "bash '$PLUG/33_mode_jour.sh'"
elif [[ "$Q" =~ (coupe.*son|mets.*muet|remet.*son|active.*son|bascule.*son|silence.*pc) ]]; then
    go "Je bascule l'état du son système, $NOM ! 🔊" "bash '$PLUG/34_bascule_son.sh'"
elif [[ "$Q" =~ (change.*voix|bascule.*voix|voix douce|voix vive|regle.*voix) ]]; then
    go "J'ouvre le sélecteur de voix, $NOM ! 🎙️" "bash '$PLUG/35_bascule_voix.sh'"

# --- 🚀 PERFORMANCE, THERMIQUE & DOCTEUR (Toutes nuances) ---
elif [[ "$Q" =~ (turbo.*ram|compresse.*ram|active.*zram|accelere.*(pc|ram|systeme)|boost.*memoire) ]]; then
    go "J'active l'accélération mémoire ZRAM et Preload, $NOM ! 🚀" "bash '$PLUG/25_turbo_zram.sh'"
elif [[ "$Q" =~ (instinct|capteur.*complet|usure.*batterie|peripherique.*usb|etat.*bluetooth) ]]; then
    go "J'affiche l'instinct matériel étendu, $NOM ! 🧬" "bash '$PLUG/26_instinct_etendu.sh'"
elif [[ "$Q" =~ (docteur|mistral|audit.*total|diagnostique.*tout|repare.*pc|verifie.*sante) ]]; then
    go "Je lance le Docteur Mistral pour un audit complet, $NOM ! 🩺" "bash '$PLUG/16_docteur_mistral.sh'"
elif [[ "$Q" =~ (stabilise.*chrome|bride.*chrome|chrome.*chauffe|chrome.*rame) ]]; then
    go "Je stabilise Google Chrome à 120% CPU max, $NOM ! 🛡️" "bash '$PLUG/10_stabiliser_chrome.sh'"
elif [[ "$Q" =~ (active.*watchdog|allume.*sentinelle|surveille.*temperature) ]]; then
    go "J'active la sentinelle thermique permanente, $NOM ! 🛡️" "bash '$PLUG/13_watchdog_on.sh'"
elif [[ "$Q" =~ (coupe.*watchdog|arrete.*sentinelle|pause.*sentinelle) ]]; then
    go "Je mets la sentinelle thermique en pause, $NOM ! ⚠️" "bash '$PLUG/14_watchdog_off.sh'"
elif [[ "$Q" =~ (sauvegarde.*matrice|fais.*backup|sauvegarde.*tout|archive.*tiffany) ]]; then
    go "Je lance la sauvegarde complète de la matrice, $NOM ! 💾" "bash '$PLUG/15_sauvegarde_matrice.sh'"
elif [[ "$Q" =~ (nettoie.*systeme|purge.*paquet|vide.*cache.*apt|grand.*menage) ]]; then
    go "Je lance le nettoyage système complet, $NOM ! 🧹" "bash '$PLUG/31_nettoyer_systeme.sh'"
elif [[ "$Q" =~ (eteins.*(pc|ordinateur|toshiba)|arrete.*ordinateur|extinction) ]]; then
    go "Extinction propre du Toshiba en cours, à bientôt $NOM ! 💤" "bash '$PLUG/Z99_eteindre_toshiba.sh'"
fi

exit 1
