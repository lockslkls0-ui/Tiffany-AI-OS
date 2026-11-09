#!/usr/bin/env bash
# ==============================================================================
# 🌹 OUTIL : centraliser_scripts.sh (v1.4 MASTER)
# 🛡️ RÔLE   : Fusionne l'intégralité du code de Tiffany dans un seul fichier texte
# ==============================================================================
SORTIE="$HOME/Desktop/TIFFANY_CODE_COMPLET.txt"
[ -d "$HOME/Bureau" ] && SORTIE="$HOME/Bureau/TIFFANY_CODE_COMPLET.txt"

echo "==================================================================" > "$SORTIE"
echo "🌹 CONFIGURATION ET IDENTITÉ GLOBALE : config_tiffany.json" >> "$SORTIE"
echo "==================================================================" >> "$SORTIE"
cat "$HOME/tiffany/config_tiffany.json" >> "$SORTIE" 2>/dev/null
echo -e "\n\n" >> "$SORTIE"

echo "==================================================================" >> "$SORTIE"
echo "🎬 PANNEAU DE CONTRÔLE PRINCIPAL : tiffany_menu.sh" >> "$SORTIE"
echo "==================================================================" >> "$SORTIE"
cat "$HOME/tiffany/tiffany_menu.sh" >> "$SORTIE" 2>/dev/null
echo -e "\n\n" >> "$SORTIE"

echo "==================================================================" >> "$SORTIE"
echo "🛡️ SCRIPTS D'ACTIONS ET INTERCEPTIONS : tiffany_actions.sh" >> "$SORTIE"
echo "==================================================================" >> "$SORTIE"
cat "$HOME/tiffany/tiffany_actions.sh" >> "$SORTIE" 2>/dev/null
echo -e "\n\n" >> "$SORTIE"

echo "==================================================================" >> "$SORTIE"
echo "🧠 NOYAU CENTRAL D'AIGUILLAGE : tiffany_core.sh" >> "$SORTIE"
echo "==================================================================" >> "$SORTIE"
cat "$HOME/tiffany/tiffany_core.sh" >> "$SORTIE" 2>/dev/null

zenity --info --title="Tiffany OS -- Centralisation" --text="🎉 Matrice centralisée avec succès !\n\nLe fichier complet a été déposé sur ton Bureau sous le nom :\n👉 TIFFANY_CODE_COMPLET.txt" --width=450 --timeout=5 2>/dev/null
