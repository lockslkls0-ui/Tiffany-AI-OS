#!/usr/bin/env bash
# ==============================================================================
# 🌹 PLUGIN : ortho.sh (Version 12.0 - UNIVERSEL PORTABLE)
# ==============================================================================
ROOT_DIR="$HOME/tiffany"
MOT=$(echo "$1" | awk '{print $2}')

if [ -z "$MOT" ]; then
    echo -e "\n🌹 Tiffany : ✍️ *Dis-moi quel mot tu veux que je vérifie, chéri.*"
    exit 0
fi

echo -e "\n🌹 Tiffany : 📖 *Recherche de '$MOT' dans mon dictionnaire français...*"

if [ ! -f "$ROOT_DIR/ressources/dictionnaire_fr.txt" ]; then
    echo -e "❌ [Erreur : Base de données dictionnaire introuvable dans $ROOT_DIR/ressources/]"
    exit 1
fi

CORRESPONDANCES=$(grep -i "^$MOT" "$ROOT_DIR/ressources/dictionnaire_fr.txt" | head -n 5)

if [ -n "$CORRESPONDANCES" ]; then
    echo -e "👉 Mots proches trouvés :\n\033[1;32m$CORRESPONDANCES\033[0m"
else
    CORRESPONDANCES_FLOU=$(grep -i "$MOT" "$ROOT_DIR/ressources/dictionnaire_fr.txt" | head -n 5)
    if [ -n "$CORRESPONDANCES_FLOU" ]; then
        echo -e "👉 Je n'ai pas trouvé de mot commençant exactement ainsi, mais voici des suggestions :\n\033[1;33m$CORRESPONDANCES_FLOU\033[0m"
    else
        echo -e "❌ [Aucune correspondance trouvée pour '$MOT']"
    fi
fi
