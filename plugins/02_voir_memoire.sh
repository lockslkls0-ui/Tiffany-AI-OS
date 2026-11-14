#!/usr/bin/env bash
# MENU_NAME: 📝 Mémoire & Journaux de Tiffany
# MENU_DESC: Lire 100% de sa mémoire, fiches Web-IA complètes, Dojo, Analyses et Discussions

ROOT_DIR="$HOME/tiffany"
TMP_VIEW="/tmp/tiffany_memoire_integrale.txt"

while true; do
    {
        echo "=========================================================================="
        echo " 🧠 ARCHIVE INTÉGRALE & CONSCIENCE TOTALE DE TIFFANY AI-OS (100% COMPLET)"
        echo "=========================================================================="
        echo "👑 Créateur officiel  : lockslkls"
        echo "👤 Utilisateur actuel : $(cat "$ROOT_DIR/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")"
        echo "🎭 Ambiance active    : $(cat "$ROOT_DIR/memory/ambiance_active.txt" 2>/dev/null || echo "complice")"
        echo ""
        echo "=========================================================================="
        echo " 1. 📌 FAITS & SOUVENIRS GRAVÉS À LONG TERME"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/memory/long_term_facts.json" ] && cat "$ROOT_DIR/memory/long_term_facts.json" || echo "Aucun fait gravé."

        echo ""
        echo "=========================================================================="
        echo " 2. 🌍 DOSSIERS & FICHES COMPLÈTES WEB-IA (Contenu intégral)"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/memory/connaissances_web.txt" ] && cat "$ROOT_DIR/memory/connaissances_web.txt"
        for d in "$HOME/Bureau/Web_IA_"* "$HOME/Desktop/Web_IA_"*; do
            [ -d "$d" ] || continue
            echo "--- 📂 Dossier : $(basename "$d") ---"
            cat "$d"/*.txt "$d"/*.md 2>/dev/null
            echo ""
        done

        echo ""
        echo "=========================================================================="
        echo " 3. 🥋 EXPLOITS DU DOJO, COMMANDES APPRISES & VARIANTES"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/dictionnaire_ia.txt" ] && cat "$ROOT_DIR/dictionnaire_ia.txt"
        [ -s "$ROOT_DIR/variantes_utilisateur.txt" ] && cat "$ROOT_DIR/variantes_utilisateur.txt"
        for s in "$ROOT_DIR/dojo/"*.sh; do
            [ -f "$s" ] || continue
            echo "--- 🥋 Script Dojo : $(basename "$s") ---"
            cat "$s"
        done

        echo ""
        echo "=========================================================================="
        echo " 4. 🔍 SANTÉ DISQUE SMART, AUDIT & ALERTES THERMIQUES"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/logs/sante_disque.txt" ] && grep -E "Power_On_Hours|Reallocated_Sector|Temperature_Celsius|UDMA_CRC" "$ROOT_DIR/logs/sante_disque.txt"
        [ -s "$ROOT_DIR/logs/audit_mistral.log" ] && cat "$ROOT_DIR/logs/audit_mistral.log"
        [ -s "$ROOT_DIR/logs/thermique.log" ] && cat "$ROOT_DIR/logs/thermique.log"

        echo ""
        echo "=========================================================================="
        echo " 5. 📖 JOURNAL DE BORD DES SESSIONS (journal_de_bord.txt)"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/memory/journal_de_bord.txt" ] && cat "$ROOT_DIR/memory/journal_de_bord.txt"

        echo ""
        echo "=========================================================================="
        echo " 6. 💬 TOUT CE QUI A ÉTÉ DIT, ENTENDU & ANALYSÉ EN DIRECT (session_raw.txt)"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/logs/session_raw.txt" ] && cat "$ROOT_DIR/logs/session_raw.txt"
    } | tr -d '\000' > "$TMP_VIEW"

    CHOIX=$(zenity --text-info --title="🧠 Mémoire Intégrale de Tiffany AI-OS (100% des Archives)" \
        --filename="$TMP_VIEW" \
        --extra-button="➕ Graver un souvenir" \
        --extra-button="🗑️ Supprimer un souvenir" \
        --width=820 --height=620 2>/dev/null)

    if [ "$CHOIX" == "➕ Graver un souvenir" ]; then
        NOUVEAU=$(zenity --entry --title="➕ Graver un Souvenir" --text="Écris une information que Tiffany doit retenir :" --width=500 2>/dev/null)
        if [ -n "$NOUVEAU" ]; then
            echo "- [$(date '+%d/%m/%Y %H:%M')] $NOUVEAU" >> "$ROOT_DIR/memory/long_term_facts.json"
        fi
    elif [ "$CHOIX" == "🗑️ Supprimer un souvenir" ]; then
        A_SUPPR=$(cat "$ROOT_DIR/memory/long_term_facts.json" 2>/dev/null | zenity --list --title="🗑️ Supprimer un Souvenir" --text="Sélectionne la ligne à effacer :" --column="Souvenirs" --width=680 --height=420 2>/dev/null)
        if [ -n "$A_SUPPR" ]; then
            grep -Fv "$A_SUPPR" "$ROOT_DIR/memory/long_term_facts.json" > "${ROOT_DIR}/memory/long_term_facts.tmp" && mv "${ROOT_DIR}/memory/long_term_facts.tmp" "$ROOT_DIR/memory/long_term_facts.json"
        fi
    else
        break
    fi
done
rm -f "$TMP_VIEW"
