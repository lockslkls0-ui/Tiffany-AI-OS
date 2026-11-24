#!/usr/bin/env bash
export PATH="$HOME/tiffany/bin:$PATH"
NOM=$(cat "$HOME/tiffany/memory/surnom_utilisateur.txt" 2>/dev/null || echo "mon ange")
say() { ("$HOME/tiffany/bin/espeak-ng" "$1" >/dev/null 2>&1) & }
case "$1" in
  heure) MSG="Il est précisément $(date +'%H heures %M'), $NOM."; echo -e "\n🌹 Tiffany : 🕒 $MSG\n"; say "$MSG" ;;
  meteo)
    V=$(echo "$2" | sed -E 's/\b(la|le|les|de|du|des|a|à|pour|sur|quel|quelle|temps|fait-il|fait|il|meteo|météo)\b//Ig' | tr -d '?!.,' | xargs)
    [ -z "$V" ] && V=$(curl -sL -m 5 "http://ip-api.com/line/?fields=city" | tr -d '\r\n')
    M=$(curl -sL -m 6 "https://wttr.in/${V// /+}?format=%l%20:%20%C,%20%t%20(ressenti%20%f),%20humidité%20%h,%20vent%20%w&lang=fr" | tr -d '\n')
    [[ -z "$M" || "$M" == *"<"* || "$M" == *"Unknown"* ]] && MSG="Météo indisponible hors ligne, $NOM." || MSG="Voici la météo à $M, $NOM."
    echo -e "\n🌹 Tiffany : 🌤️ $MSG\n"; say "$MSG" ;;
  minuteur)
    MINS=$(echo "$2" | grep -oE '[0-9]+' | head -n 1); [ -z "$MINS" ] && MINS=5
    echo -e "\n🌹 Tiffany : ⏰ Minuteur de $MINS min lancé, $NOM.\n"; say "Minuteur de $MINS minutes lancé, $NOM."
    (sleep $((MINS*60)); notify-send -u critical "⏰ Rappel Tiffany" "Temps écoulé, $NOM !"; "$HOME/tiffany/bin/espeak-ng" "Minuteur de $MINS minutes écoulé, $NOM !" >/dev/null 2>&1) & ;;
esac
