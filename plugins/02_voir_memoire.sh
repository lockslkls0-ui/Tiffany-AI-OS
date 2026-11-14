#!/usr/bin/env bash
# MENU_NAME: 📝 Mémoire & Journaux de Tiffany
# MENU_DESC: Lire, ajouter ou supprimer des souvenirs et consulter toutes ses archives

ROOT_DIR="$HOME/tiffany"
TMP_VIEW="/tmp/tiffany_memoire_integrale.txt"

while true; do
    {
        echo "=========================================================================="
        echo " 🧠 ARCHIVE INTÉGRALE & CONSCIENCE TOTALE DE TIFFANY AI-OS (100% EN DIRECT)"
        echo "=========================================================================="
        echo "👑 Créateur officiel  : lockslkls"
        echo "👤 Utilisateur actuel : $(cat "$ROOT_DIR/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")"
        echo "🎭 Ambiance active    : $(cat "$ROOT_DIR/memory/ambiance_active.txt" 2>/dev/null || echo "complice")"
        echo ""
        echo "=========================================================================="
        echo " 1. 📌 FAITS & SOUVENIRS GRAVÉS À LONG TERME (long_term_facts.json)"
        echo "=========================================================================="
        if [ -s "$ROOT_DIR/memory/long_term_facts.json" ]; then
            cat "$ROOT_DIR/memory/long_term_facts.json"
        else
            echo "Aucun fait gravé pour le moment."
        fi

        echo ""
        echo "=========================================================================="
        echo " 2. 🌍 CONNAISSANCES WEB-IA & DOSSIERS ENCYCLOPÉDIQUES (Bureau & Web)"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/memory/connaissances_web.txt" ] && cat "$ROOT_DIR/memory/connaissances_web.txt" || echo "Aucune fiche Web enregistrée."
        ls -dt "$HOME/Bureau/Web_IA_"* "$HOME/Desktop/Web_IA_"* 2>/dev/null | head -n 10 | while read -r d; do
            echo "  📂 Dossier archivé : $(basename "$d")"
        done

        echo ""
        echo "=========================================================================="
        echo " 3. 🥋 EXPLOITS DU DOJO, COMMANDES APPRISES & VARIANTES"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/dictionnaire_ia.txt" ] && cat "$ROOT_DIR/dictionnaire_ia.txt" || echo "Aucune commande réflexe."
        [ -s "$ROOT_DIR/variantes_utilisateur.txt" ] && cat "$ROOT_DIR/variantes_utilisateur.txt" || echo "Aucune variante."
        ls -lt "$ROOT_DIR/dojo/"*.sh 2>/dev/null | head -n 10 | awk '{print "  🥋 " $9}' || echo "Aucun script dans le Dojo."

        echo ""
        echo "=========================================================================="
        echo " 4. 🔍 SANTÉ DISQUE SMART, AUDIT & ALERTES THERMIQUES"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/logs/sante_disque.txt" ] && grep -E "Power_On_Hours|Reallocated_Sector|Temperature_Celsius|UDMA_CRC" "$ROOT_DIR/logs/sante_disque.txt"
        [ -s "$ROOT_DIR/logs/audit_mistral.log" ] && tail -n 20 "$ROOT_DIR/logs/audit_mistral.log"
        [ -s "$ROOT_DIR/logs/thermique.log" ] && tail -n 10 "$ROOT_DIR/logs/thermique.log"

        echo ""
        echo "=========================================================================="
        echo " 5. 📖 JOURNAL DE BORD & FIL DE DISCUSSION"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/memory/journal_de_bord.txt" ] && cat "$ROOT_DIR/memory/journal_de_bord.txt"
        [ -s "$ROOT_DIR/logs/session_raw.txt" ] && tail -n 30 "$ROOT_DIR/logs/session_raw.txt"
    } > "$TMP_VIEW"

    CHOIX=$(zenity --text-info --title="🧠 Mémoire Intégrale de Tiffany AI-OS" \
        --filename="$TMP_VIEW" \
        --extra-button="➕ Graver un souvenir" \
        --extra-button="🗑️ Supprimer un souvenir" \
        --width=780 --height=600 2>/dev/null)

    if [ "$CHOIX" == "➕ Graver un souvenir" ]; then
        NOUVEAU=$(zenity --entry --title="➕ Graver un Souvenir" --text="Écris une information que Tiffany doit retenir :" --width=500 2>/dev/null)
        if [ -n "$NOUVEAU" ]; then
            echo "- [$(date '+%d/%m/%Y %H:%M')] $NOUVEAU" >> "$ROOT_DIR/memory/long_term_facts.json"
            notify-send -u low -t 2500 -i "emblem-favorite" "🧠 Souvenir Gravé" "$NOUVEAU" >/dev/null 2>&1
        fi
    elif [ "$CHOIX" == "🗑️ Supprimer un souvenir" ]; then
        if [ ! -s "$ROOT_DIR/memory/long_term_facts.json" ]; then
            zenity --info --title="Mémoire vide" --text="Aucun fait gravé à supprimer dans long_term_facts.json." --width=360 2>/dev/null
            continue
        fi
        A_SUPPR=$(cat "$ROOT_DIR/memory/long_term_facts.json" | zenity --list --title="🗑️ Supprimer un Souvenir" \
            --text="Sélectionne le souvenir à effacer définitivement :" \
            --column="Souvenirs enregistrés" --width=680 --height=420 2>/dev/null)
        if [ -n "$A_SUPPR" ]; then
            grep -Fv "$A_SUPPR" "$ROOT_DIR/memory/long_term_facts.json" > "${ROOT_DIR}/memory/long_term_facts.tmp" && mv "${ROOT_DIR}/memory/long_term_facts.tmp" "$ROOT_DIR/memory/long_term_facts.json"
            notify-send -u low -t 2500 -i "user-trash" "🗑️ Souvenir Effacé" "Supprimé de la mémoire." >/dev/null 2>&1
        fi
    else
        break
    fi
done
rm -f "$TMP_VIEW"
