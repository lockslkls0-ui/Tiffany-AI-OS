#!/usr/bin/env bash
# MENU_NAME: ⏰ Planificateur & Réveils
# MENU_DESC: Programmer une action différée, voir ou annuler les tâches en attente

while true; do
    TACHES=$(atq 2>/dev/null | awk '{print "ID #" $1 " -> Prévu le " $2 " " $3 " " $4 " à " $5}')
    [ -z "$TACHES" ] && TACHES="Aucune tâche programmée actuellement."

    ACTION_MENU=$(zenity --list --title="⏰ Planificateur & Réveils — Tiffany AI-OS" \
        --text="📋 Tâches en attente :\n$TACHES\n\nChoisis une opération :" \
        --column="Action" --column="Détail" \
        "➕ Programmer une nouvelle tâche" "Exécuter un ordre dans X minutes ou à une heure précise" \
        "🗑️ Annuler une tâche programmée" "Supprimer un réveil ou une action en attente" \
        "❌ Fermer" "Revenir au Panneau Tiffany" \
        --width=560 --height=360 2>/dev/null)

    case "$ACTION_MENU" in
        "➕ Programmer une nouvelle tâche")
            ORDRE=$(zenity --entry --title="⏰ Action à programmer" \
                --text="Quelle commande Tiffany doit-elle exécuter ?\n(ex: coupe la radio, nettoie la ram, mode froid, eteins l ordinateur)" \
                --entry-text="coupe la radio" --width=480 2>/dev/null)
            [ -z "$ORDRE" ] && continue

            QUAND=$(zenity --entry --title="⏳ Délai ou Heure" \
                --text="Quand dois-je l'exécuter ?\n• En minutes : 15 (pour dans 15 minutes)\n• À une heure précise : 23:30" \
                --entry-text="15" --width=420 2>/dev/null)
            [ -z "$QUAND" ] && continue

            if [[ "$QUAND" =~ ^[0-9]+$ ]]; then
                echo "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus bash '$HOME/tiffany/tiffany_actions.sh' '$ORDRE'" | at "now + ${QUAND} minutes" >/dev/null 2>&1
                notify-send -u low -t 3000 -i "alarm-symbolic" "⏰ Tâche Programmée" "« $ORDRE » s'exécutera dans $QUAND minutes."
            elif [[ "$QUAND" =~ ^[0-9]{1,2}:[0-9]{2}$ ]]; then
                echo "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus bash '$HOME/tiffany/tiffany_actions.sh' '$ORDRE'" | at "$QUAND" >/dev/null 2>&1
                notify-send -u low -t 3000 -i "alarm-symbolic" "⏰ Tâche Programmée" "« $ORDRE » s'exécutera à $QUAND."
            else
                zenity --error --text="Format invalide. Écris soit un nombre de minutes (ex: 15), soit une heure (ex: 23:30)." --width=360 2>/dev/null
            fi
            ;;
        "🗑️ Annuler une tâche programmée")
            LISTE_IDS=$(atq 2>/dev/null | awk '{print $1 " | " $2 " " $3 " " $4 " à " $5}')
            if [ -z "$LISTE_IDS" ]; then
                zenity --info --text="Aucune tâche à annuler." --width=280 2>/dev/null
                continue
            fi
            CIBLE=$(echo "$LISTE_IDS" | zenity --list --title="🗑️ Annuler une tâche" --text="Sélectionne la tâche à supprimer :" --column="Tâches programmées" --width=450 --height=300 2>/dev/null)
            if [ -n "$CIBLE" ]; then
                JOB_ID=$(echo "$CIBLE" | awk '{print $1}')
                atrm "$JOB_ID" 2>/dev/null
                notify-send -u low -t 2500 -i "user-trash" "🗑️ Tâche Annulée" "La tâche #$JOB_ID a été supprimée."
            fi
            ;;
        *)
            break
            ;;
    esac
done
