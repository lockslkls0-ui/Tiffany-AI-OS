#!/bin/bash
# MENU_NAME: 📻 Allumer la Radio
# MENU_DESC: Mode Zapping, Ajouts et Suppressions
DB_RADIOS="$HOME/.tiffany_radios.txt"
RADIO_GEO="$HOME/.tiffany_radio_geo.txt"
CATALOGUE="$HOME/.catalogue_geant.txt"
if [ ! -f "$RADIO_GEO" ]; then echo "450 250 540 500" > "$RADIO_GEO"; fi
while true; do
    read -r RX RY RW RH < "$RADIO_GEO"
    [ -z "$RW" ] && RW=540; [ -z "$RH" ] && RH=500
    ZENITY_ARGS=()
    while IFS='|' read -r nom url; do [ -n "$nom" ] && [ -n "$url" ] && ZENITY_ARGS+=("🎵 $nom" "$url"); done < "$DB_RADIOS"
    ZENITY_ARGS+=("🎲 LANCER UNE RADIO AU HASARD (ZAPPING)" "action_aleatoire" "✨ RAJOUTER UN FLUX MANUEL" "action_ajouter" "🗑️  SUPPRIMER UNE RADIO DE LA LISTE" "action_supprimer" "❌ Fermer le Lecteur" "quitter")
    ( for i in {1..15}; do sleep 0.01; WID=$(xdotool search --name "TIFFANY_RADIO" 2>/dev/null | head -n 1); if [ -n "$WID" ]; then xdotool windowsize "$WID" "$RW" "$RH"; xdotool windowmove "$WID" "$RX" "$RY"; break; fi; done ) &
    STATION=$(zenity --list --title="TIFFANY_RADIO" --column="Mes Stations / Outils" --column="Flux URL" --print-column=2 --width="$RW" --height="$RH" "${ZENITY_ARGS[@]}" 2>/dev/null)
    WID_CUR=$(xdotool search --name "TIFFANY_RADIO" 2>/dev/null | head -n 1)
    if [ -n "$WID_CUR" ]; then eval $(xdotool getwindowgeometry --shell "$WID_CUR" 2>/dev/null); echo "$X $Y $WIDTH $HEIGHT" > "$RADIO_GEO"; fi
    if [ $? -ne 0 ] || [ -z "$STATION" ] || [[ "$STATION" == "quitter" ]]; then break; fi
    if [[ "$STATION" == "action_aleatoire" ]]; then
        LIGNE_RANDOM=$(shuf -n 1 "$CATALOGUE"); RANDOM_NOM=$(echo "$LIGNE_RANDOM" | cut -d'|' -f1); RANDOM_URL=$(echo "$LIGNE_RANDOM" | cut -d'|' -f2)
        pkill -9 -x "mpv" >/dev/null 2>&1; pkill -9 -x "vlc" >/dev/null 2>&1
        if ! pgrep -x "rhythmbox" >/dev/null; then rhythmbox >/dev/null 2>&1 & sleep 2.5; fi
        rhythmbox-client --play-uri="$RANDOM_URL" >/dev/null 2>&1
        zenity --question --title="🎲 Zapping Actif" --text="📻 Station : $RANDOM_NOM\n\n👉 Enregistrer ?" --width=400 2>/dev/null
        if [ $? -eq 0 ] && ! grep -q "$RANDOM_URL" "$DB_RADIOS"; then echo "$RANDOM_NOM|$RANDOM_URL" >> "$DB_RADIOS"; fi
    elif [[ "$STATION" == "action_ajouter" ]]; then
        NOM=$(zenity --entry --title="🌹 Ajouter" --text="Nom :" 2>/dev/null); URL=$(zenity --entry --title="🌹 URL" --text="Lien :" 2>/dev/null)
        if [ -n "$NOM" ] && [ -n "$URL" ]; then echo "$NOM|$URL" >> "$DB_RADIOS"; fi
    elif [[ "$STATION" == "action_supprimer" ]]; then
        LISTE_SUP=()
        while IFS='|' read -r nom url; do [ -n "$nom" ] && LISTE_SUP+=("$nom" "$nom"); done < "$DB_RADIOS"
        CIBLE=$(zenity --list --title="Supprimer ?" --column="Nom" --column="Sélection" --hide-column=1 "${LISTE_SUP[@]}" 2>/dev/null)
        if [ -n "$CIBLE" ]; then sed -i "s|^$CIBLE\|.*||" "$DB_RADIOS"; sed -i '/^$/d' "$DB_RADIOS"; fi
    else
        pkill -9 -x "mpv" >/dev/null 2>&1
        if ! pgrep -x "rhythmbox" >/dev/null; then rhythmbox >/dev/null 2>&1 & sleep 2.5; fi
        rhythmbox-client --play-uri="$STATION" >/dev/null 2>&1
    fi
done
