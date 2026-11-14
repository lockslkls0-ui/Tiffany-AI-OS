#!/usr/bin/env bash
# MENU_NAME: ⏰ Planificateur & Réveils
# MENU_DESC: Programmer une action différée, voir ou annuler les tâches en attente

DB_JOBS="$HOME/tiffany/memory/taches_planifiees.txt"
mkdir -p "$(dirname "$DB_JOBS")"
touch "$DB_JOBS"

while true; do
    # Nettoyer les tâches déjà exécutées qui ne sont plus dans atq
    ACTIFS=$(atq 2>/dev/null | awk '{print $1}')
    > "${DB_JOBS}.tmp"
    while IFS='|' read -r jid desc heure; do
        if echo "$ACTIFS" | grep -qw "$jid"; then
            echo "$jid|$desc|$heure" >> "${DB_JOBS}.tmp"
        fi
    done < "$DB_JOBS"
    mv "${DB_JOBS}.tmp" "$DB_JOBS"

    TACHES=$(awk -F'|' '{print "• " $2 " (" $3 ")"}' "$DB_JOBS")
    [ -z "$TACHES" ] && TACHES="Aucune tâche programmée actuellement."

    ACTION_MENU=$(zenity --list --title="⏰ Planificateur & Réveils — Tiffany AI-OS" \
        --text="📋 Tâches programmées en attente :\n$TACHES\n\nChoisis une opération :" \
        --column="Action" --column="Détail" \
        "➕ Programmer une nouvelle tâche" "Exécuter un ordre dans X minutes ou à une heure précise" \
        "🗑️ Annuler une tâche programmée" "Supprimer une action en attente" \
        "❌ Fermer" "Revenir au Panneau Tiffany" \
        --width=580 --height=380 2>/dev/null)

    case "$ACTION_MENU" in
        "➕ Programmer une nouvelle tâche")
            ORDRE=$(zenity --entry --title="⏰ Action à programmer" \
                --text="Quelle commande Tiffany doit-elle exécuter ?\n(ex: coupe la radio, nettoie la ram, mode froid, eteins l ordinateur)" \
                --entry-text="coupe la radio" --width=480 2>/dev/null)
            [ -z "$ORDRE" ] && continue

            QUAND=$(zenity --entry --title="⏳ Délai ou Heure" \
                --text="Quand dois-je l'exécuter ?\n• En minutes : 15 (dans 15 minutes)\n• À une heure précise : 23:30" \
                --entry-text="15" --width=420 2>/dev/null)
            [ -z "$QUAND" ] && continue

            if [[ "$QUAND" =~ ^[0-9]+$ ]]; then
                OUT=$(echo "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus bash '$HOME/tiffany/tiffany_actions.sh' '$ORDRE'" | at "now + ${QUAND} minutes" 2>&1)
                JID=$(echo "$OUT" | grep -oE 'job [0-9]+' | awk '{print $2}')
                [ -n "$JID" ] && echo "$JID|$ORDRE|dans $QUAND min" >> "$DB_JOBS"
                notify-send -u low -t 3000 -i "alarm-symbolic" "⏰ Tâche Programmée" "« $ORDRE » s'exécutera dans $QUAND minutes."
            elif [[ "$QUAND" =~ ^[0-9]{1,2}:[0-9]{2}$ ]]; then
                OUT=$(echo "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus bash '$HOME/tiffany/tiffany_actions.sh' '$ORDRE'" | at "$QUAND" 2>&1)
                JID=$(echo "$OUT" | grep -oE 'job [0-9]+' | awk '{print $2}')
                [ -n "$JID" ] && echo "$JID|$ORDRE|à $QUAND" >> "$DB_JOBS"
                notify-send -u low -t 3000 -i "alarm-symbolic" "⏰ Tâche Programmée" "« $ORDRE » s'exécutera à $QUAND."
            else
                zenity --error --text="Format invalide. Écris soit un nombre de minutes (ex: 15), soit une heure (ex: 23:30)." --width=360 2>/dev/null
            fi
            ;;
        "🗑️ Annuler une tâche programmée")
            if [ ! -s "$DB_JOBS" ]; then
                zenity --info --text="Aucune tâche à annuler." --width=280 2>/dev/null
                continue
            fi
            LISTE_CHOIX=()
            while IFS='|' read -r jid desc heure; do
                LISTE_CHOIX+=("$jid" "$desc ($heure)")
            done < "$DB_JOBS"
            CIBLE=$(zenity --list --title="🗑️ Annuler une tâche" --text="Sélectionne l'action à supprimer :" --hide-column=1 --column="ID" --column="Action programmée" "${LISTE_CHOIX[@]}" --width=480 --height=300 2>/dev/null)
            if [ -n "$CIBLE" ]; then
                atrm "$CIBLE" 2>/dev/null
                grep -v "^${CIBLE}|" "$DB_JOBS" > "${DB_JOBS}.tmp" && mv "${DB_JOBS}.tmp" "$DB_JOBS"
                notify-send -u low -t 2500 -i "user-trash" "🗑️ Tâche Annulée" "L'action programmée a été supprimée."
            fi
            ;;
        *)
            break
            ;;
    esac
done
