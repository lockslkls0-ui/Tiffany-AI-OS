#!/bin/bash
# MENU_NAME: 📻 INTERCEPTER RHYTHMBOX
# MENU_DESC: Télécharge le morceau en cours avec suivi de progression
INFOS_MUSIQUE=$(rhythmbox-client --print-playing 2>/dev/null)
if [[ "$INFOS_MUSIQUE" == *"#"* ]] || [ -z "$INFOS_MUSIQUE" ] || [ "$INFOS_MUSIQUE" == "Pas de lecture en cours" ]; then
    INFOS_MUSIQUE=$(zenity --entry --title="Intercepteur -- Tiffany" --text="Saisis l'artiste ou le morceau chéri :" --width=400 2>/dev/null)
fi
if [ -n "$INFOS_MUSIQUE" ]; then
    ( 
        echo "# 🔍 Radar sémantique actif... Recherche sur YouTube..."; sleep 1
        yt-dlp -x --audio-format mp3 -o "$HOME/Musique/%(title)s.%(ext)s" "ytsearch1:$INFOS_MUSIQUE" 2>&1 | stdbuf -oL tr "\r" "\n" | sed -u -n "s/.*\\[download\\][[:space:]]*\([0-9.]*\)%.*/\1/p" | while read -r pct; do 
            val=$(echo "$pct" | cut -d. -f1); echo "$val"; echo "# 📥 Aspiration : $val% ..."
        done
        echo "100" ; sleep 0.5
    ) | zenity --progress --title="Tiffany OS" --text="Initialisation..." --percentage=0 --auto-close --width=400 2>/dev/null
    if [ $? -eq 0 ]; then
        zenity --info --title="Tiffany OS" --text="✅ Piste audio ajoutée avec succès !" --timeout=3 2>/dev/null
    fi
fi
