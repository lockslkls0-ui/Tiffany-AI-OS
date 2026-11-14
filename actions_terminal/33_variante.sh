#!/usr/bin/env bash
# TERM_KEY: variante
# TERM_DESC: Ajouter un synonyme ou une traduction dans n importe quelle langue
# TERM_ICON: 🌍

VAR_FILE="$HOME/tiffany/variantes_utilisateur.txt"
SAISIE=$(zenity --forms --title="🌍 Ajouter une Variante / Traduction" \
    --text="Associe n'importe quelle phrase (FR, EN, argot...) à une commande Tiffany :" \
    --add-entry="Ta phrase (ex: mets le turbo / next song)" \
    --add-entry="Commande cible (ex: boost / next / analyse / radio)" \
    --width=500 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$SAISIE" ]; then
    PHRASE=$(echo "$SAISIE" | cut -d'|' -f1 | tr 'A-Z' 'a-z' | sed 's/[éèêë]/e/g; s/[àâ]/a/g' | xargs)
    CIBLE=$(echo "$SAISIE" | cut -d'|' -f2- | tr 'A-Z' 'a-z' | xargs)
    if [ -n "$PHRASE" ] && [ -n "$CIBLE" ]; then
        echo "${PHRASE}|${CIBLE}" >> "$VAR_FILE"
        echo -e "\n\033[1;32m🌍 [Variante Enregistrée] :\033[0m '$PHRASE' ➔ '$CIBLE'\n"
    fi
fi
