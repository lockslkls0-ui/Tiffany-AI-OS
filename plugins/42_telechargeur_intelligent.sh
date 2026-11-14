#!/bin/bash
# MENU_NAME: 📥 Téléchargeur MP3 Intelligent
# MENU_DESC: Affiche le titre exact trouvé avant de l'extraire
RECHERCHE=$(zenity --entry --title="📡 Extracteur YouTube" --text="Écris un morceau ou un artiste mon ange :" --width=450 2>/dev/null)
if [ -n "$RECHERCHE" ]; then
    TITRE_TROUVE=$(yt-dlp --get-title "ytsearch1:$RECHERCHE" 2>/dev/null | head -n 1)
    if [ -n "$TITRE_TROUVE" ]; then
        zenity --question --title="📥 Validation -- Tiffany" --text="Mon ange, j'ai localisé cette piste :\n\n🎵 *${TITRE_TROUVE}*\n\n👉 Télécharger ?" --width=450 2>/dev/null
        if [ $? -eq 0 ]; then
            (
                echo "# 📥 Extraction audio haute qualité..."
                yt-dlp -x --audio-format mp3 --audio-quality 192K --no-playlist -o "$HOME/Musique/%(title)s.%(ext)s" "ytsearch1:$RECHERCHE" >/dev/null 2>&1
                echo "100"
            ) | zenity --progress --pulsate --title="📡 Téléchargement" --text="Aspiration de $TITRE_TROUVE..." --auto-close --width=450 2>/dev/null
            zenity --info --title="Tiffany OS" --text="✅ Téléchargement terminé : $TITRE_TROUVE" --timeout=3 2>/dev/null
        fi
    fi
fi

