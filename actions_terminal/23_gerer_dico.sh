#!/usr/bin/env bash
# TERM_KEY: gerer
# TERM_DESC: Gérer, modifier ou supprimer les commandes apprises (Liste)
# TERM_ICON: 📝

DICO_IA="$HOME/tiffany/actions_terminal/dictionnaire_ia.txt"
touch "$DICO_IA"

while true; do
    ARGS=()
    while IFS='|' read -r alias_cmd action_cmd; do
        [[ -z "$alias_cmd" || -z "$action_cmd" || "$alias_cmd" == -* ]] && continue
        ARGS+=("$alias_cmd" "$action_cmd")
    done < "$DICO_IA"

    CHOIX=$(zenity --list --title="📝 Mémoire Réflexe de Tiffany" \
        --text="Sélectionne une commande pour la modifier ou la supprimer :" \
        --column="Alias / Phrase" --column="Commande exécutée" \
        --extra-button="➕ Ajouter une nouvelle" \
        "${ARGS[@]}" --width=800 --height=450 2>/dev/null)

    CODE=$?
    if [[ "$CHOIX" == "➕ Ajouter une nouvelle" ]]; then
        bash "$HOME/tiffany/actions_terminal/22_apprends.sh"
        continue
    fi
    [ $CODE -ne 0 ] || [ -z "$CHOIX" ] && break

    CMD_ACTUELLE=$(grep -F "${CHOIX}|" "$DICO_IA" | head -n 1 | cut -d'|' -f2-)
    ACTION=$(zenity --list --title="Action sur : $CHOIX" \
        --column="Choix" "✏️ Modifier l'alias ou la commande" "🗑️ Supprimer ce réflexe" \
        --width=400 --height=220 2>/dev/null)

    if [[ "$ACTION" == *"Supprimer"* ]]; then
        grep -vF "${CHOIX}|" "$DICO_IA" > "${DICO_IA}.tmp" && mv "${DICO_IA}.tmp" "$DICO_IA"
        zenity --info --text="🗑️ Réflexe '$CHOIX' supprimé !" --timeout=2 2>/dev/null
    elif [[ "$ACTION" == *"Modifier"* ]]; then
        MODIF=$(zenity --forms --title="✏️ Modifier le réflexe" \
            --add-entry="Nouvel Alias (Actuel : $CHOIX)" \
            --add-entry="Nouvelle Commande (Actuelle : $CMD_ACTUELLE)" \
            --width=550 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$MODIF" ]; then
            N_ALIAS=$(echo "$MODIF" | cut -d'|' -f1 | tr 'A-Z' 'a-z' | sed 's/[éèêë]/e/g' | sed 's/[àâ]/a/g' | xargs)
            N_CMD=$(echo "$MODIF" | cut -d'|' -f2- | xargs)
            [ -z "$N_ALIAS" ] && N_ALIAS="$CHOIX"
            [ -z "$N_CMD" ] && N_CMD="$CMD_ACTUELLE"
            grep -vF "${CHOIX}|" "$DICO_IA" > "${DICO_IA}.tmp"
            echo "${N_ALIAS}|${N_CMD}" >> "${DICO_IA}.tmp"
            mv "${DICO_IA}.tmp" "$DICO_IA"
            zenity --info --text="✅ Réflexe mis à jour !" --timeout=2 2>/dev/null
        fi
    fi
done
