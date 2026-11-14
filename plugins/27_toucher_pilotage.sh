#!/usr/bin/env bash
# MENU_NAME: 🖱️ Télécommande Tactile PC
# MENU_DESC: Télécommande rapide (Onglets, Plein écran, Clic, Verrouillage)

ACTION=$(zenity --list --title="🖱️ Télécommande Tactile Tiffany" \
    --column="Action" --column="Commande" \
    "⬇️ Descendre la page" "descends" \
    "⬆️ Remonter la page" "monte" \
    "📑 Onglet suivant (Ctrl+Tab)" "onglet" \
    "🖥️ Plein écran (F11)" "plein ecran" \
    "🔒 Verrouiller le PC" "verrouille" \
    --width=420 --height=300 2>/dev/null)

[ -z "$ACTION" ] && exit 0
sleep 0.4
case "$ACTION" in
    *"Descendre"*) bash "$HOME/tiffany/actions_terminal/26_pilote.sh" descends ;;
    *"Remonter"*) bash "$HOME/tiffany/actions_terminal/26_pilote.sh" monte ;;
    *"Onglet"*) bash "$HOME/tiffany/actions_terminal/26_pilote.sh" onglet ;;
    *"Plein"*) bash "$HOME/tiffany/actions_terminal/26_pilote.sh" plein ecran ;;
    *"Verrouiller"*) bash "$HOME/tiffany/actions_terminal/26_pilote.sh" verrouille ;;
esac
