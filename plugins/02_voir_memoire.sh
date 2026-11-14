#!/usr/bin/env bash
# MENU_NAME: 📝 Mémoire & Journaux de Tiffany
# MENU_DESC: Lire tous ses souvenirs, son journal de bord et ses rapports SMART (Défilant)

ROOT_DIR="$HOME/tiffany"
TMP_VIEW="/tmp/tiffany_memoire_vue.txt"

{
    echo "=================================================================="
    echo " 🧠 MÉMOIRE TOTALE & CONSCIENCE DE TIFFANY AI-OS"
    echo "=================================================================="
    echo "👑 Créateur officiel : lockslkls"
    echo "👤 Utilisateur actuel : $(cat "$ROOT_DIR/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")"
    echo ""
    echo "--- 📌 FAITS GRAVÉS À LONG TERME (Illimité) ---"
    if [ -s "$ROOT_DIR/memory/long_term_facts.json" ]; then
        cat "$ROOT_DIR/memory/long_term_facts.json"
    else
        echo "Aucun fait gravé pour le moment."
    fi
    echo ""
    echo "--- 🌍 CONNAISSANCES WEB-IA APPRISES ---"
    [ -s "$ROOT_DIR/memory/connaissances_web.txt" ] && tail -n 15 "$ROOT_DIR/memory/connaissances_web.txt" || echo "Aucune fiche Web-IA."
    echo ""
    echo "--- 📖 JOURNAL DE BORD DES SESSIONS ---"
    [ -s "$ROOT_DIR/memory/journal_de_bord.txt" ] && tail -n 25 "$ROOT_DIR/memory/journal_de_bord.txt" || echo "Aucune session archivée."
    echo ""
    echo "--- 💬 FIL DE LA SESSION EN COURS ---"
    [ -s "$ROOT_DIR/logs/session_raw.txt" ] && tail -n 20 "$ROOT_DIR/logs/session_raw.txt" || echo "Début de session."
    echo ""
    echo "--- 🩺 DERNIER RAPPORT DOCTEUR & SANTÉ DISQUE (SMART) ---"
    [ -s "$ROOT_DIR/logs/sante_disque.txt" ] && grep -E "Power_On_Hours|Reallocated_Sector|Temperature_Celsius|UDMA_CRC" "$ROOT_DIR/logs/sante_disque.txt" || echo "Disque non scanné."
    [ -s "$ROOT_DIR/logs/audit_mistral.log" ] && tail -n 12 "$ROOT_DIR/logs/audit_mistral.log"
} > "$TMP_VIEW"

zenity --text-info --title="🧠 Mémoire Totale & Journaux de Tiffany (Illimité)" \
    --filename="$TMP_VIEW" \
    --extra-button="➕ Graver un nouveau souvenir" \
    --width=720 --height=560 2>/dev/null

if [ $? -eq 1 ] && grep -q "" "$TMP_VIEW"; then
    # Si l'utilisateur clique sur "➕ Graver un nouveau souvenir"
    NOUVEAU=$(zenity --entry --title="🧠 Graver un Souvenir" --text="Écris une information importante que Tiffany doit retenir pour toujours :" --width=480 2>/dev/null)
    if [ -n "$NOUVEAU" ]; then
        echo "- [$(date '+%d/%m/%Y')] $NOUVEAU" >> "$ROOT_DIR/memory/long_term_facts.json"
        notify-send -u low -t 3000 -i "emblem-favorite" "🧠 Souvenir Gravé" "Tiffany retiendra : $NOUVEAU" >/dev/null 2>&1
    fi
fi
rm -f "$TMP_VIEW"
