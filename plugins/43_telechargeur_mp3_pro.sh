#!/usr/bin/env bash
# TERM_KEY: telechargeur mp3 pro
# TERM_DESC: Télécharger une musique en MP3 et l'ajouter à Rhythmbox
# TERM_ICON: 🎧
Q="$*"
[ -z "$Q" ] && Q=$(zenity --entry --title="🎧 Téléchargeur MP3 Pro" --text="Nom de l'artiste ou du titre :" 2>/dev/null)
[ -z "$Q" ] && exit 0
mkdir -p "$HOME/Musique"
TITRE=$(yt-dlp --no-update --get-title "ytsearch1:$Q" 2>/dev/null | head -n 1)
[ -z "$TITRE" ] && echo "❌ Aucun résultat pour : $Q" && exit 0
nohup bash -c 'yt-dlp --no-update -x --audio-format mp3 --audio-quality 192K --no-playlist -o "$HOME/Musique/%(title)s.%(ext)s" "ytsearch1:'"$Q"'" >/dev/null 2>&1 && F=$(ls -t "$HOME/Musique"/*.mp3 2>/dev/null | head -n 1) && [ -n "$F" ] && (pgrep -x rhythmbox >/dev/null || nohup rhythmbox >/dev/null 2>&1 &) && sleep 2 && rhythmbox-client --enqueue "$F" >/dev/null 2>&1' >/dev/null 2>&1 &
echo "📥 Téléchargement lancé : $TITRE"
