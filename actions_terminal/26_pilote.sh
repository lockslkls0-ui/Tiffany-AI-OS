#!/usr/bin/env bash
# TERM_KEY: pilote
# TERM_DESC: Contrôler la souris, le défilement, les onglets et l ecran
# TERM_ICON: 🖱️

ORDRE=$(echo "$*" | tr 'A-Z' 'a-z' | sed 's/[éèêë]/e/g; s/[àâ]/a/g')

if [[ "$ORDRE" =~ (descend|bas|scroll) ]]; then
    xdotool click 5; xdotool click 5; xdotool click 5; xdotool click 5
    echo "🖱️ Page descendue."
elif [[ "$ORDRE" =~ (monte|haut) ]]; then
    xdotool click 4; xdotool click 4; xdotool click 4; xdotool click 4
    echo "🖱️ Page remontée."
elif [[ "$ORDRE" =~ (onglet|suivant) ]]; then
    xdotool key ctrl+Tab
    echo "🖱️ Onglet suivant."
elif [[ "$ORDRE" =~ (ferme.*onglet) ]]; then
    xdotool key ctrl+w
    echo "🖱️ Onglet fermé."
elif [[ "$ORDRE" =~ (plein ecran|agrandis) ]]; then
    xdotool key F11
    echo "🖱️ Bascule plein écran."
elif [[ "$ORDRE" =~ (clic|clique) ]]; then
    xdotool click 1
    echo "🖱️ Clic effectué."
elif [[ "$ORDRE" =~ (verrouille|lock) ]]; then
    bash "$HOME/tiffany/tiffany_utilitaire.sh" lock
else
    echo "🖱️ Commandes pilote : pilote descends | pilote monte | pilote onglet | pilote clic | pilote plein ecran | pilote verrouille"
fi
