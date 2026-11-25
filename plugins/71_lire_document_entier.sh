#!/bin/bash
# MENU_NAME: 📖 Lire un document en entier (Pause / Stop)
# MENU_DESC: Lit intégralement un fichier PDF, TXT ou Markdown avec Pause et Arrêt

FICHIER=$(zenity --file-selection --title="Choisis le document à lire en entier" --filename="$(xdg-user-dir DESKTOP)/WebIA_Dossiers/")
[ -z "$FICHIER" ] && exit 0

MODELE_PIPER=$(find ~/tiffany -name "*.onnx" | head -n 1)
BIN_PIPER=$(command -v piper || find ~/tiffany ~/.local -name "piper" -type f -executable 2>/dev/null | head -n 1)

if [[ "$FICHIER" == *.pdf ]]; then
    CONTENU=$(pdftotext "$FICHIER" -)
else
    CONTENU=$(cat "$FICHIER")
fi

touch /tmp/tiffany_parle.lock

(
    echo "$CONTENU" | sed 's/[#*`>-]//g; s/—/-/g' | grep -v '^[[:space:]]*$' | while IFS= read -r LIGNE; do
        [ ! -f /tmp/tiffany_parle.lock ] && break
        if [ -n "$BIN_PIPER" ] && [ -n "$MODELE_PIPER" ]; then
            echo "$LIGNE" | "$BIN_PIPER" --model "$MODELE_PIPER" --output-raw 2>/dev/null | aplay -r 16000 -f S16_LE -t raw -q 2>/dev/null
        else
            espeak-ng -v fr -s 145 "$LIGNE" 2>/dev/null
        fi
    done
    rm -f /tmp/tiffany_parle.lock
) &
PID_LECTURE=$!

EN_PAUSE=0
while kill -0 $PID_LECTURE 2>/dev/null; do
    if [ $EN_PAUSE -eq 0 ]; then
        zenity --question --title="Tiffany lit ton document..." \
            --text="📖 Lecture en cours :\n$(basename "$FICHIER")" \
            --ok-label="⏸️ Pause" --cancel-label="⏹️ Arrêter"
        if [ $? -eq 0 ]; then
            kill -STOP $PID_LECTURE 2>/dev/null
            killall -STOP aplay espeak-ng 2>/dev/null
            EN_PAUSE=1
        else
            break
        fi
    else
        zenity --question --title="Lecture en PAUSE" \
            --text="⏸️ En pause sur :\n$(basename "$FICHIER")" \
            --ok-label="▶️ Reprendre" --cancel-label="⏹️ Arrêter"
        if [ $? -eq 0 ]; then
            killall -CONT aplay espeak-ng 2>/dev/null
            kill -CONT $PID_LECTURE 2>/dev/null
            EN_PAUSE=0
        else
            break
        fi
    fi
done

rm -f /tmp/tiffany_parle.lock
killall -CONT aplay espeak-ng 2>/dev/null
kill -9 $PID_LECTURE 2>/dev/null
killall -9 piper aplay espeak-ng 2>/dev/null
