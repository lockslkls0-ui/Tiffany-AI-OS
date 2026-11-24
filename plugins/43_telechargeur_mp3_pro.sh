#!/usr/bin/env bash
# MENU_NAME: 🎧 Téléchargeur MP3 Pro (Top 10)
# MENU_DESC: Recherche Top 10 YouTube, téléchargement MP3 et lecture Rhythmbox
# TERM_KEY: telechargeur mp3 pro

RECHERCHE="$*"
if [ -z "$RECHERCHE" ]; then
    RECHERCHE=$(zenity --entry --title="🎧 Téléchargeur MP3 Pro" --text="Quel artiste ou morceau cherches-tu ?" --width=450 2>/dev/null)
fi
[ -z "$RECHERCHE" ] && exit 0

RESULTATS=$(yt-dlp --flat-playlist --print "%(id)s|%(title)s (%(duration_string)s)" "ytsearch10:$RECHERCHE" 2>/dev/null)
if [ -z "$RESULTATS" ]; then
    echo "❌ Aucun résultat trouvé pour : $RECHERCHE"
    exit 1
fi

ARGS=()
while IFS='|' read -r vid titre; do
    [ -n "$vid" ] && [ -n "$titre" ] && ARGS+=("$vid" "$titre")
done <<< "$RESULTATS"

CHOIX_ID=$(zenity --list --title="🎧 Top 10 YouTube : $RECHERCHE" \
    --text="Sélectionne le morceau à télécharger en MP3 :" \
    --hide-column=1 --column="ID" --column="Titre & Durée" \
    "${ARGS[@]}" --width=580 --height=420 2>/dev/null)

[ -z "$CHOIX_ID" ] && exit 0

mkdir -p "$HOME/Musique"
H="https://"
D="://youtube.com"
P="/watch?v="
URL_YT="${H}${D}${P}${CHOIX_ID}"

yt-dlp -x --audio-format mp3 --audio-quality 192K --no-playlist -o "$HOME/Musique/%(title)s.%(ext)s" "$URL_YT" >/dev/null 2>&1
FICHIER_MP3=$(ls -t "$HOME/Musique"/*.mp3 2>/dev/null | head -n 1)

if [ -n "$FICHIER_MP3" ] && [ -f "$FICHIER_MP3" ]; then
    pgrep -x rhythmbox >/dev/null || (nohup rhythmbox >/dev/null 2>&1 & sleep 2)
    rhythmbox-client --play-uri="file://$FICHIER_MP3" >/dev/null 2>&1 &
    echo "✅ MP3 téléchargé et lancé dans Rhythmbox : $(basename "$FICHIER_MP3")"
    zenity --info --title="🎧 Téléchargeur MP3 Pro" --text="✅ Téléchargé et lancé dans Rhythmbox :\n$(basename "$FICHIER_MP3")" --timeout=4 --width=420 2>/dev/null
else
    echo "❌ Échec du téléchargement MP3."
fi
