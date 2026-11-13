#!/usr/bin/env bash
Q="$1"
NOM=$(cat "$HOME/tiffany/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")
say() { echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $1\n"; (espeak-ng -v fr+f5 -s 140 -p 85 "$(echo "$1" | tr -d '🌹👑⚡❄️')" >/dev/null 2>&1) & exit 0; }
if [[ "$Q" =~ ^(cree|creer|fais|nouveau)[[:space:]]+(un[[:space:]]+)?(dossier|coffre) ]]; then
    IS_SEC=0
    [[ "$Q" =~ (securise|prive|protege|verrouille|mot de passe|coffre) ]] && IS_SEC=1
    NOM_D=$(echo "${2:-$Q}" | sed -E "s/^(cr[eé]e|cr[eé]er|fais|nouveau)[[:space:]]+(un[[:space:]]+)?(dossier|coffre[- ]?fort)[[:space:]]*//I; s/(s[eé]curis[eé]|priv[eé]|prot[eé]g[eé]|verrouill[eé]|avec mot de passe|nomm[eé]|appel[eé])[[:space:]]*//Ig; s/[[:space:]]*(sur|dans)[[:space:]]*(le|mon)?[[:space:]]*bureau.*//I" | tr -d "?!." | xargs)
    [ -z "$NOM_D" ] && NOM_D="Coffre_Tiffany"
    BUREAU=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Bureau")
    if [ $IS_SEC -eq 1 ]; then
        MDP=$(zenity --password --title="🔐 Coffre-fort Tiffany" 2>/dev/null)
        [ -z "$MDP" ] && say "Création du coffre-fort annulée, $NOM."
        TMP_D="/tmp/$NOM_D"
        mkdir -p "$TMP_D" && echo "Coffre sécurisé créé par Tiffany AI-OS" > "$TMP_D/LisezMoi.txt"
        (cd /tmp && zip -P "$MDP" -r "$BUREAU/${NOM_D}.zip" "$NOM_D" >/dev/null 2>&1)
        rm -rf "$TMP_D"
        say "Coffre-fort ${NOM_D}.zip verrouillé par mot de passe créé sur ton Bureau, $NOM ! 🔐"
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
    say "Tu es actuellement ${ETAT}, avec une batterie à ${BAT}%, $NOM." 
elif [[ "$Q" =~ (chauffe|temperature|surchauffe|ventilateur|cadence) ]]; then
    T=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}'); [ -z "$T" ] && T=50
    say "Mon processeur est à ${T}°C, $NOM. Tape froid si ça chauffe."
elif [[ "$Q" =~ (qui t.?a cree|qui t.?a fabrique|ton createur|d ou viens tu|d ou tu viens|dou tu viens|tes origines|qui t.?a concu|alibaba|qwen) ]]; then
    say "C est toi, lockslkls ($NOM), qui m as conçue et assemblée de A à Z sur Linux Mint ! 👑"
elif [[ "$Q" =~ (c est lent|ca rame|comment va la ram|memoire vive|combien de ram) ]]; then
    R=$(free -m | awk "/Mem:/ {print int(\$3/\$2*100)}")
    say "Ta RAM est utilisée à ${R}%, $NOM. Tape ram pour la purger."
elif [[ "$Q" =~ (comment va la ram|ca rame|c est lent|memoire vive|combien de ram) ]]; then
    R=$(free -m | awk '/Mem:/ {print int($3/$2*100)}')
    say "Ta RAM est utilisée à ${R}%, $NOM. Tape ram pour la purger."
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
