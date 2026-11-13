#!/usr/bin/env bash
Q="$1"
NOM=$(cat "$HOME/tiffany/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")
say() { echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $1\n"; (espeak-ng -v fr+f5 -s 140 -p 85 "$(echo "$1" | tr -d '🌹👑⚡❄️')" >/dev/null 2>&1) & exit 0; }
if [[ "$Q" =~ (batterie|chargeur|branche|secteur|autonomie|jus) ]]; then
    BAT=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo "100")
    ST=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1)
    if [[ "$ST" == "Charging" || "$ST" == "Full" ]]; then ETAT="branché sur secteur"; else ETAT="débranché (sur batterie)"; fi
    say "Tu es actuellement ${ETAT}, avec une batterie à ${BAT}%, $NOM." 
elif [[ "$Q" =~ (chauffe|temperature|surchauffe|ventilateur|cadence) ]]; then
    T=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}'); [ -z "$T" ] && T=50
    say "Mon processeur est à ${T}°C, $NOM. Tape froid si ça chauffe."
elif [[ "$Q" =~ (qui t.?a cree|qui t.?a fabrique|ton createur|qui t.?a concu|alibaba|qwen) ]]; then
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
