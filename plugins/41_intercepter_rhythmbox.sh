#!/bin/bash
# MENU_NAME: 🎧 Intercepter Rhythmbox (MP3)
# MENU_DESC: Télécharge le morceau en cours avec barre fluide
INFOS_MUSIQUE=$(rhythmbox-client --print-playing 2>/dev/null)
if [[ "$INFOS_MUSIQUE" == *"#"* ]] || [[ "$INFOS_MUSIQUE" == -* ]] || [[ "$INFOS_MUSIQUE" == *"favori"* ]] || [ -z "$INFOS_MUSIQUE" ] || [ "$INFOS_MUSIQUE" == "Pas de lecture en cours" ] || [[ "$INFOS_MUSIQUE" == http* ]]; then
    INFOS_MUSIQUE=$(zenity --entry --title="Intercepteur -- Tiffany" --text="Saisis l'artiste ou le morceau chéri :" --width=400 2>/dev/null)
else
    zenity --question --title="📻 Interception détectée" --text="Mon ange, tu écoutes :\n\n🎵 *${INFOS_MUSIQUE}*\n\n👉 Télécharger ce morceau en MP3 ?" --width=420 2>/dev/null
    [ $? -ne 0 ] && exit 0
fi

if [ -n "$INFOS_MUSIQUE" ]; then
    (
        echo "# 🔍 Aspiration et conversion MP3 en cours pour : $INFOS_MUSIQUE..."
        yt-dlp -x --audio-format mp3 --audio-quality 192K --no-playlist -o "$HOME/Musique/%(title)s.%(ext)s" "ytsearch1:$INFOS_MUSIQUE" >/dev/null 2>&1
        echo "100"
    ) | zenity --progress --pulsate --title="📻 Intercepteur Tiffany" --text="Recherche et téléchargement..." --auto-close --width=420 2>/dev/null
    if [ $? -eq 0 ]; then
        zenity --info --title="Tiffany OS" --text="✅ Piste ajoutée à ta musique, mon amour !" --timeout=3 2>/dev/null
    fi
fi

