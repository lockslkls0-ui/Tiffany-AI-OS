#!/usr/bin/env bash
# TERM_KEY: pilote
# TERM_DESC: Contrôler la souris, le défilement, les onglets et l ecran
# TERM_ICON: 🖱️

ORDRE=$(echo "$*" | tr 'A-Z' 'a-z' | sed 's/[éèêë]/e/g; s/[àâ]/a/g')
say() { (espeak-ng -v fr+f5 -s 145 -p 85 "$1" >/dev/null 2>&1) & }

if [[ "$ORDRE" =~ (droite) ]]; then
    xdotool mousemove_relative -- 150 0
    echo "🖱️ Souris déplacée à droite." ; say "Souris à droite."
elif [[ "$ORDRE" =~ (gauche) ]]; then
    xdotool mousemove_relative -- -150 0
    echo "🖱️ Souris déplacée à gauche." ; say "Souris à gauche."
elif [[ "$ORDRE" =~ (monte|haut) ]]; then
    xdotool click 4; xdotool click 4; xdotool click 4; xdotool click 4
    echo "🖱️ Page remontée." ; say "Je remonte la page."
elif [[ "$ORDRE" =~ (descend|bas|scroll) ]]; then
    xdotool click 5; xdotool click 5; xdotool click 5; xdotool click 5
    echo "🖱️ Page descendue." ; say "Je descends la page."
elif [[ "$ORDRE" =~ (onglet|suivant) ]]; then
    xdotool key ctrl+Tab
    echo "🖱️ Onglet suivant." ; say "Onglet suivant."
elif [[ "$ORDRE" =~ (ferme.*onglet) ]]; then
    xdotool key ctrl+w
    echo "🖱️ Onglet fermé." ; say "Onglet fermé."
elif [[ "$ORDRE" =~ (plein ecran|agrandis) ]]; then
    xdotool key F11
    echo "🖱️ Bascule plein écran." ; say "Plein écran."
elif [[ "$ORDRE" =~ (double clic) ]]; then
    xdotool click --repeat 2 1
    echo "🖱️ Double-clic effectué." ; say "Double clic."
elif [[ "$ORDRE" =~ (clic droit) ]]; then
    xdotool click 3
    echo "🖱️ Clic droit effectué." ; say "Clic droit."
elif [[ "$ORDRE" =~ (clic|clique) ]]; then
    xdotool click 1
    echo "🖱️ Clic gauche effectué." ; say "Clic effectué."
elif [[ "$ORDRE" =~ (verrouille|lock) ]]; then
    say "Je verrouille ton écran mon ange."
    bash "$HOME/tiffany/tiffany_utilitaire.sh" lock
else
    echo "🖱️ Commandes pilote : droite | gauche | monte | descends | onglet | clic | clic droit | double clic | plein ecran | verrouille"
fi
