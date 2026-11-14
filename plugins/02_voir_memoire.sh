#!/usr/bin/env bash
# MENU_NAME: 📝 Mémoire & Journaux de Tiffany
# MENU_DESC: Voir l intégralité absolue de sa mémoire (Faits, Web-IA, Dojo, Analyses, SMART, Logs)

ROOT_DIR="$HOME/tiffany"
TMP_VIEW="/tmp/tiffany_memoire_integrale.txt"

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
    if [ -s "$ROOT_DIR/memory/connaissances_web.txt" ]; then
        cat "$ROOT_DIR/memory/connaissances_web.txt"
    else
        echo "Aucune fiche Web enregistrée dans connaissances_web.txt."
    fi
    ls -dt "$HOME/Bureau/Web_IA_"* "$HOME/Desktop/Web_IA_"* 2>/dev/null | head -n 10 | while read -r d; do
        echo "  📂 Dossier archivé : $(basename "$d")"
    done

    echo ""
    echo "=========================================================================="
    echo " 3. 🥋 EXPLOITS DU DOJO, COMMANDES APPRISES & VARIANTES (Auto-évolution)"
    echo "=========================================================================="
    echo "--- Commandes apprises (dictionnaire_ia.txt) ---"
    [ -s "$ROOT_DIR/dictionnaire_ia.txt" ] && cat "$ROOT_DIR/dictionnaire_ia.txt" || echo "Aucune commande réflexe."
    echo "--- Variantes & Traductions personnalisées (variantes_utilisateur.txt) ---"
    [ -s "$ROOT_DIR/variantes_utilisateur.txt" ] && cat "$ROOT_DIR/variantes_utilisateur.txt" || echo "Aucune variante."
    echo "--- Scripts forgés dans le Dojo (~/tiffany/dojo/) ---"
    ls -lt "$ROOT_DIR/dojo/"*.sh 2>/dev/null | head -n 10 | awk '{print "  🥋 " $9 " (" $6 " " $7 " " $8 ")"}' || echo "Aucun script dans le Dojo."

    echo ""
    echo "=========================================================================="
    echo " 4. 🔍 RAPPORTS D'ANALYSE, SANTÉ DISQUE SMART & ALERTES THERMIQUES"
    echo "=========================================================================="
    if [ -s "$ROOT_DIR/logs/sante_disque.txt" ]; then
        echo "--- Usure Disque Dur (SMART) ---"
        grep -E "Power_On_Hours|Reallocated_Sector|Temperature_Celsius|UDMA_CRC" "$ROOT_DIR/logs/sante_disque.txt"
    fi
    if [ -s "$ROOT_DIR/logs/audit_mistral.log" ]; then
        echo "--- Dernier Audit Docteur Mistral ---"
        tail -n 25 "$ROOT_DIR/logs/audit_mistral.log"
    fi
    if [ -s "$ROOT_DIR/logs/thermique.log" ]; then
        echo "--- Journal Thermique (Watchdog) ---"
        tail -n 15 "$ROOT_DIR/logs/thermique.log"
    fi

    echo ""
    echo "=========================================================================="
    echo " 5. 📖 JOURNAL DE BORD DES SESSIONS PASSÉES (journal_de_bord.txt)"
    echo "=========================================================================="
    [ -s "$ROOT_DIR/memory/journal_de_bord.txt" ] && cat "$ROOT_DIR/memory/journal_de_bord.txt" || echo "Aucune session archivée."

    echo ""
    echo "=========================================================================="
    echo " 6. 💬 FIL DE LA DISCUSSION EN COURS (session_raw.txt)"
    echo "=========================================================================="
    [ -s "$ROOT_DIR/logs/session_raw.txt" ] && tail -n 40 "$ROOT_DIR/logs/session_raw.txt" || echo "Début de session."
} > "$TMP_VIEW"

zenity --text-info --title="🧠 Mémoire Intégrale de Tiffany AI-OS (100% des Archives)" \
    --filename="$TMP_VIEW" \
    --extra-button="➕ Graver un nouveau souvenir" \
    --width=780 --height=600 2>/dev/null

if [ $? -eq 1 ]; then
    NOUVEAU=$(zenity --entry --title="🧠 Graver un Souvenir" --text="Écris une information importante que Tiffany doit retenir pour toujours :" --width=500 2>/dev/null)
    if [ -n "$NOUVEAU" ]; then
        echo "- [$(date '+%d/%m/%Y %H:%M')] $NOUVEAU" >> "$ROOT_DIR/memory/long_term_facts.json"
        notify-send -u low -t 3000 -i "emblem-favorite" "🧠 Souvenir Gravé" "Tiffany retiendra : $NOUVEAU" >/dev/null 2>&1
    fi
fi
rm -f "$TMP_VIEW"
