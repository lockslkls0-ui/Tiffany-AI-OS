#!/usr/bin/env bash
# TERM_KEY: apprends
# TERM_DESC: Enseigner manuellement une commande et un alias via Zenity
# TERM_ICON: 🎓

DICO_IA="$HOME/tiffany/actions_terminal/dictionnaire_ia.txt"

SAISIE=$(zenity --forms --title="🎓 Enseigner à Tiffany" \
    --text="Apprends-moi un nouveau réflexe instantané, mon ange :" \
    --add-entry="Phrase ou Alias (ex: vide telechargements)" \
    --add-entry="Commande Bash exacte (ex: rm -rf ~/Téléchargements/*)" \
    --width=500 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$SAISIE" ]; then
    PHRASE=$(echo "$SAISIE" | cut -d'|' -f1 | tr 'A-Z' 'a-z' | sed 's/[éèêë]/e/g' | sed 's/[àâ]/a/g' | xargs)
    CMD=$(echo "$SAISIE" | cut -d'|' -f2- | xargs)
    
    if [ -n "$PHRASE" ] && [ -n "$CMD" ]; then
        echo "${PHRASE}|${CMD}" >> "$DICO_IA"
        echo -e "\n\033[1;32m🎓 [Nouveau Réflexe Gravé] :\033[0m '$PHRASE' ➔ '$CMD'\n"
        (espeak-ng -v fr+f5 -s 140 -p 85 "C'est gravé dans ma mémoire réflexe mon amour." >/dev/null 2>&1) &
    fi
fi
