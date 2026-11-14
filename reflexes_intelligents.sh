#!/usr/bin/env bash
Q="$1"
NOM=$(cat "$HOME/tiffany/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")
say_alea() {
    local ITEMS=("$@")
    local CHOIX="${ITEMS[$RANDOM % ${#ITEMS[@]}]}"
    local DEB=145
    [ "$(cat "$HOME/tiffany/memory/ambiance_active.txt" 2>/dev/null)" == "zen" ] && DEB=128
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $CHOIX\n"
    pkill -x espeak-ng >/dev/null 2>&1
    (espeak-ng -v fr+f5 -s "$DEB" -p 85 "$(echo "$CHOIX" | tr -d '🌹👑⚡❄️🔋💾🩺🧠')" >/dev/null 2>&1) &
    exit 0
}
say() { echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $1\n"; pkill -x espeak-ng >/dev/null 2>&1; (espeak-ng -v fr+f5 -s 140 -p 85 "$(echo "$1" | tr -d '🌹👑⚡❄️')" >/dev/null 2>&1) & exit 0; }
if [[ "$Q" =~ ^(ouvre[[:space:]]+)?(le[[:space:]]+)?terminal$ ]]; then
    gnome-terminal >/dev/null 2>&1 &
    say "J'ouvre un terminal Linux pour toi, $NOM ! 💻"
elif [[ "$Q" =~ (panneau de commande|ton menu|ouvre.*menu|affiche.*panneau) ]]; then
    bash "$HOME/tiffany/tiffany_menu.sh" >/dev/null 2>&1 &
    say "J'ouvre mon panneau de commande graphique, $NOM ! 🌹"
elif [[ "$Q" =~ (ta discussion|ouvre.*discussion|parler a tiffany|discuter avec toi) ]]; then
    gnome-terminal --title="🌹 Discussion Tiffany" -- bash -c "$HOME/tiffany/tiffany_core.sh" >/dev/null 2>&1 &
    say "J'ouvre notre espace de discussion, $NOM ! 💬"
elif [[ "$Q" =~ (lis.*(page|dossier|fiche|web|article)|lecture.*web) ]]; then
    bash "$HOME/tiffany/actions_terminal/31_lire_webia.sh"
    exit 0
elif [[ "$Q" =~ ^(tais[- ]toi|stop.*voix|arrete.*lire|chut)$ ]]; then
    pkill -x espeak-ng >/dev/null 2>&1
    exit 0
elif [[ "$Q" =~ ^(deverrouille|libere|debloque)[[:space:]]+(le[[:space:]]+)?(coffre|dossier) ]]; then
    NOM_C=$(echo "${2:-$Q}" | sed -E "s/^(d[eé]verrouille|lib[eè]re|d[eé]bloque)[[:space:]]+(le[[:space:]]+)?(coffre[- ]?fort|dossier)[[:space:]]*//I; s/[[:space:]]*(sur|dans)[[:space:]]*(le|mon)?[[:space:]]*bureau.*//I" | tr -d "?!." | xargs)
    BUREAU=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Bureau")
    F_CIBLE="$BUREAU/${NOM_C}.7z"
    [ ! -f "$F_CIBLE" ] && F_CIBLE="$BUREAU/${NOM_C}"
    if [ -e "$F_CIBLE" ]; then
        pkexec chattr -i "$F_CIBLE" && say "Verrou anti-suppression retiré sur $(basename "$F_CIBLE"), $NOM ! 🔓"
    else
        say "Je ne trouve pas $NOM_C sur ton Bureau, $NOM."
    fi
elif [[ "$Q" =~ ^(cree|creer|fais|nouveau)[[:space:]]+(un[[:space:]]+)?(dossier|coffre) ]]; then
    IS_SEC=0
    [[ "$Q" =~ (securise|prive|protege|verrouille|mot de passe|coffre) ]] && IS_SEC=1
    NOM_D=$(echo "${2:-$Q}" | sed -E "s/^(cr[eé]e|cr[eé]er|fais|nouveau)[[:space:]]+(un[[:space:]]+)?(dossier|coffre[- ]?fort)[[:space:]]*//I; s/(s[eé]curis[eé]|priv[eé]|prot[eé]g[eé]|verrouill[eé]|avec mot de passe|nomm[eé]|appel[eé])[[:space:]]*//Ig; s/[[:space:]]*(sur|dans)[[:space:]]*(le|mon)?[[:space:]]*bureau.*//I" | tr -d "?!." | xargs)
    [ -z "$NOM_D" ] && NOM_D="Coffre_Tiffany"
    BUREAU=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Bureau")
    if [ $IS_SEC -eq 1 ]; then
        ARCHIVE="$BUREAU/${NOM_D}.7z"
        CMD_SHOW="7z a -p[MDP] -mhe=on '$ARCHIVE' && pkexec chattr +i '$ARCHIVE'"
        if zenity --question --no-markup --title="🛡️ Validation Coffre-Fort" --text="Autoriser la création de ce coffre-fort chiffré ?

$CMD_SHOW" --width=540 2>/dev/null; then
            MDP=$(zenity --password --title="🔐 Mot de passe du coffre $NOM_D" 2>/dev/null)
            [ -z "$MDP" ] && say "Création annulée, $NOM."
            mkdir -p "/tmp/$NOM_D" && echo "Coffre-fort chiffré par Tiffany AI-OS" > "/tmp/$NOM_D/LisezMoi.txt"
            7z a -p"$MDP" -mhe=on "$ARCHIVE" "/tmp/$NOM_D" >/dev/null 2>&1
            rm -rf "/tmp/$NOM_D" && pkexec chattr +i "$ARCHIVE"
            say "Coffre-fort intégral ${NOM_D}.7z verrouillé par mot de passe créé sur ton Bureau, $NOM ! 🔐"
        else
            say "Création annulée, $NOM."
        fi
    else
        CIBLE="$BUREAU/$NOM_D"
        if zenity --question --no-markup --title="🛡️ Validation Tiffany" --text="Autoriser la création du dossier ?

mkdir -p '$CIBLE'" --width=480 2>/dev/null; then
            mkdir -p "$CIBLE" && say "Dossier $NOM_D créé sur ton Bureau, $NOM ! 📁"
        else
            say "Création annulée, $NOM."
        fi
    fi
elif [[ "$Q" =~ (batterie|chargeur|branche|secteur|autonomie|jus) ]]; then
    BAT=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo "100")
    ST=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1)
    if [[ "$ST" == "Charging" || "$ST" == "Full" ]]; then ETAT="branché sur secteur"; else ETAT="débranché (sur batterie)"; fi
    say_alea "Tu es actuellement ${ETAT}, avec une batterie à ${BAT}%, $NOM. 🔋" "Côté énergie, ton PC est ${ETAT} et la batterie affiche ${BAT}%, $NOM. 🔋" "La batterie est à ${BAT}% et ton ordinateur est ${ETAT}, $NOM. 🔋" 
elif [[ "$Q" =~ (chauffe|temperature|surchauffe|ventilateur|cadence) ]]; then
    T=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}'); [ -z "$T" ] && T=50
    say_alea "Mon processeur tourne à ${T}°C en ce moment, $NOM. 🌡️" "La sonde thermique indique ${T}°C sur le CPU, $NOM. 🌡️" "Tout est sous contrôle : le processeur est à ${T}°C, $NOM. 🌡️"
elif [[ "$Q" =~ ^(merci|cimer|top|parfait|super|genial|nikel|nickel) ]]; then
    say "Avec grand plaisir, $NOM ! Je veille sur tout. 🌹"
elif [[ "$Q" =~ ^(bonjour|salut|coucou|hello|hey|yo|bonsoir) ]]; then
    say "Coucou $NOM ! Tout est frais et opérationnel sur ton Toshiba. Que faisons-nous ? 🌹"
elif [[ "$Q" =~ (tu dors|es tu la|tu es la|tu m entends|reveille) ]]; then
    say "Je ne dors jamais, $NOM ! Mon oreille et mon bouclier thermique veillent en permanence. ⚡"
elif [[ "$Q" =~ (age.*disque|heures.*disque|smart|sante.*disque|usure.*disque) ]]; then
    H=$(grep "Power_On_Hours" "$HOME/tiffany/logs/sante_disque.txt" 2>/dev/null | awk '{print $NF}')
    CRC=$(grep "UDMA_CRC_Error_Count" "$HOME/tiffany/logs/sante_disque.txt" 2>/dev/null | awk '{print $NF}')
    JOURS=$(( ${H:-8884} / 24 ))
    say "Ton disque dur totalise ${H:-8884} heures de fonctionnement (environ ${JOURS} jours) et ${CRC:-243} erreurs de câble CRC, $NOM. 💾"
elif [[ "$Q" =~ (rapport.*erreur|erreurs.*systeme|dernier.*audit|journal.*erreur) ]]; then
    ERR=$(journalctl -p 3 -n 1 --no-pager -q 2>/dev/null | cut -d' ' -f5- | head -c 110)
    say "Dernière alerte système relevée : ${ERR:-Aucune erreur critique détectée}, $NOM. 🩺"
elif [[ "$Q" =~ (de quoi tu te souviens|tes souvenirs|mes souvenirs|lis.*souvenir|nos sessions) ]]; then
    FAITS=$(grep -v '^{' "$HOME/tiffany/memory/long_term_facts.json" 2>/dev/null | tail -n 3 | tr '\n' ' ' | sed 's/^- //g' | xargs)
    say "Voici mes derniers souvenirs gravés : ${FAITS:-Nous construisons Tiffany AI-OS ensemble sur ton Toshiba}, $NOM ! 🧠"
elif [[ "$Q" =~ (qui t.?a cree|qui t.?a fabrique|ton createur|d ou viens tu|d ou tu viens|dou tu viens|tes origines|qui t.?a concu|alibaba|qwen) ]]; then
    say_alea "C est Lorian (lockslkls) qui m a conçue et assemblée de A à Z sur Linux Mint ! 👑" "Mon créateur officiel est Lorian (lockslkls), c est lui qui a forgé toute ma matrice sur Linux Mint ! 👑" "Je dois mon existence à Lorian (lockslkls), mon concepteur sur Linux Mint ! 👑"
elif [[ "$Q" =~ (c est lent|ca rame|comment va la ram|memoire vive|combien de ram) ]]; then
    R=$(free -m | awk "/Mem:/ {print int(\$3/\$2*100)}")
    say_alea "Ta mémoire vive est occupée à ${R}%, $NOM. 🧠" "Côté RAM, tu utilises actuellement ${R}% de la mémoire, $NOM. 🧠" "La mémoire vive est à ${R}% d occupation, $NOM. 🧠"
elif [[ "$Q" =~ (comment va la ram|ca rame|c est lent|memoire vive|combien de ram) ]]; then
    R=$(free -m | awk '/Mem:/ {print int($3/$2*100)}')
    say_alea "Ta mémoire vive est occupée à ${R}%, $NOM. 🧠" "Côté RAM, tu utilises actuellement ${R}% de la mémoire, $NOM. 🧠" "La mémoire vive est à ${R}% d occupation, $NOM. 🧠"
elif [[ "$Q" =~ (combien de place|espace disque|prend de la place|lourd|disque plein|stockage) ]]; then
    L=$(df -h / | awk 'NR==2 {print $4}')
    say "Il te reste ${L} de libre sur ton disque, $NOM."
elif [[ "$Q" =~ (j ai internet|mon ip|quel wifi|je suis connecte|reseau) ]]; then
    IP=$(hostname -I | awk '{print $1}')
    say "Ton adresse IP locale est ${IP:-deconnecte}, $NOM."
elif [[ "$Q" =~ (quel(le)? jour|la date|on est le combien) ]]; then
    say "Nous sommes le $(LC_TIME=fr_FR.UTF-8 date '+%A %d %B %Y'), $NOM."
elif [[ "$Q" =~ (allume depuis|temps d activite|uptime) ]]; then
    say "Ton PC tourne depuis $(uptime -p | sed 's/up //'), $NOM."
elif [[ "$Q" =~ (quel.*volume|le son est a|niveau.*son) ]]; then
    VOL=$(amixer get Master 2>/dev/null | grep -oE '[0-9]+%' | head -n 1)
    say "Le volume est à ${VOL:-inconnu}, $NOM."
elif [[ "$Q" =~ (watchdog|bouclier|protege|bilan rapide) ]]; then
    WD=$(pgrep -f "watchdog.sh" >/dev/null && echo "active" || echo "en veille")
    say "La sentinelle thermique est ${WD}, $NOM."
fi
exit 1
