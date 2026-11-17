#!/usr/bin/env bash
export PATH="$HOME/tiffany/bin:$PATH"
NOM=$(cat "$HOME/tiffany/memory/surnom_utilisateur.txt" 2>/dev/null || echo "mon ange")
say() { ("$HOME/tiffany/bin/espeak-ng" "$1" >/dev/null 2>&1) & }

ACTION="$1"
DETAIL="$2"

case "$ACTION" in
    "heure")
        HEURE_STR=$(date +"%H heures %M")
        MSG="Il est précisément $HEURE_STR, $NOM."
        echo -e "\n🌹 Tiffany : 🕒 $MSG\n"
        say "$MSG"
        ;;
    "meteo")
        echo -e "\n🌹 Tiffany : *Sondage météo en cours...*"
        METEO=$(curl -s --max-time 4 "wttr.in?format=3&lang=fr" | tr -d '\n')
        [ -z "$METEO" ] && METEO="temps agréable sur ton secteur"
        MSG="Voici la météo actuelle : $METEO, $NOM."
        echo -e "🌹 Tiffany : 🌤️ $MSG\n"
        say "$MSG"
        ;;
    "minuteur")
        MINS=$(echo "$DETAIL" | grep -oE '[0-9]+' | head -n 1)
        [ -z "$MINS" ] && MINS=5
        SECS=$((MINS * 60))
        MSG="Minuteur de $MINS minutes lancé en arrière-plan, $NOM."
        echo -e "\n🌹 Tiffany : ⏰ $MSG\n"
        say "$MSG"
        (
            sleep "$SECS"
            notify-send -u critical -i "alarm-symbolic" "⏰ Rappel Tiffany" "Le temps est écoulé, $NOM !"
            "$HOME/tiffany/bin/espeak-ng" "Attention $NOM, ton minuteur de $MINS minutes est écoulé !" >/dev/null 2>&1
        ) &
        ;;
esac
