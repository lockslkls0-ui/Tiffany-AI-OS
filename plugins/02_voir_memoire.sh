#!/usr/bin/env bash
# MENU_NAME: 📝 Mémoire & Journaux de Tiffany
# MENU_DESC: Lire 100% des fiches Web-IA complètes, ajouter, modifier ou supprimer des souvenirs

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
        echo " 2. 🌍 INTÉGRALITÉ DES FICHES WEB & WEB-IA (Porc au sucre, Pierre Decker, etc.)"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/memory/connaissances_web.txt" ] && cat "$ROOT_DIR/memory/connaissances_web.txt"
        find "$HOME" -maxdepth 3 -iname "*web*ia*" -o -iname "*dossier*web*" 2>/dev/null | sort -u | while read -r item; do
            if [ -d "$item" ]; then
                echo -e "\n--- 📂 DOSSIER : $item ---"
                find "$item" -type f \( -name "*.txt" -o -name "*.md" \) -exec cat {} + 2>/dev/null
            elif [ -f "$item" ]; then
                echo -e "\n--- 📄 FICHIER : $item ---"
                cat "$item" 2>/dev/null
            fi
        done

        echo ""
        echo "=========================================================================="
        echo " 3. 🥋 EXPLOITS DU DOJO, COMMANDES APPRISES & VARIANTES"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/dictionnaire_ia.txt" ] && cat "$ROOT_DIR/dictionnaire_ia.txt"
        [ -s "$ROOT_DIR/variantes_utilisateur.txt" ] && cat "$ROOT_DIR/variantes_utilisateur.txt"
        for s in "$ROOT_DIR/dojo/"*.sh; do
            [ -f "$s" ] && echo "--- 🥋 $(basename "$s") ---" && cat "$s"
        done

        echo ""
        echo "=========================================================================="
        echo " 4. 🔍 SANTÉ DISQUE SMART, AUDIT & ALERTES THERMIQUES"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/logs/sante_disque.txt" ] && grep -E "Power_On_Hours|Reallocated_Sector|Temperature_Celsius|UDMA_CRC" "$ROOT_DIR/logs/sante_disque.txt"
        [ -s "$ROOT_DIR/logs/audit_mistral.log" ] && tail -n 25 "$ROOT_DIR/logs/audit_mistral.log"
        [ -s "$ROOT_DIR/logs/thermique.log" ] && tail -n 15 "$ROOT_DIR/logs/thermique.log"

        echo ""
        echo "=========================================================================="
        echo " 5. 📖 JOURNAL DE BORD DES SESSIONS"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/memory/journal_de_bord.txt" ] && cat "$ROOT_DIR/memory/journal_de_bord.txt"

        echo ""
        echo "=========================================================================="
        echo " 6. 💬 FIL DES DISCUSSIONS & COMMANDES EN DIRECT"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/logs/session_raw.txt" ] && tail -n 60 "$ROOT_DIR/logs/session_raw.txt"
    } | tr -d '\000' > "$TMP_VIEW"

    CHOIX=$(zenity --text-info --title="🧠 Mémoire Intégrale de Tiffany AI-OS" \
        --filename="$TMP_VIEW" \
        --extra-button="➕ Ajouter" \
        --extra-button="✏️ Modifier" \
        --extra-button="🗑️ Supprimer" \
        --width=820 --height=620 2>/dev/null)

    case "$CHOIX" in
        "➕ Ajouter")
            NOUVEAU=$(zenity --entry --title="➕ Ajouter un Souvenir" --text="Écris le souvenir à graver :" --width=500 2>/dev/null)
            [ -n "$NOUVEAU" ] && echo "- [$(date '+%d/%m/%Y %H:%M')] $NOUVEAU" >> "$ROOT_DIR/memory/long_term_facts.json"
            ;;
        "✏️ Modifier")
            LIGNE=$(cat "$ROOT_DIR/memory/long_term_facts.json" "$ROOT_DIR/memory/journal_de_bord.txt" 2>/dev/null | grep -v "^$" | zenity --list --title="✏️ Modifier un Souvenir" --text="Choisis la ligne à modifier :" --column="Mémoire enregistrée" --width=700 --height=450 2>/dev/null)
            if [ -n "$LIGNE" ]; then
                MODIF=$(zenity --entry --title="✏️ Éditer" --text="Modifie le texte :" --entry-text="$LIGNE" --width=550 2>/dev/null)
                if [ -n "$MODIF" ]; then
                    python3 -c '
import sys
old, new = sys.argv[1], sys.argv[2]
for p in sys.argv[3:]:
    try:
        txt = open(p, encoding="utf-8", errors="ignore").read()
        if old in txt:
            open(p, "w", encoding="utf-8").write(txt.replace(old, new))
    except Exception:
        pass
' "$LIGNE" "$MODIF" "$ROOT_DIR/memory/long_term_facts.json" "$ROOT_DIR/memory/journal_de_bord.txt"
                fi
            fi
            ;;
        "🗑️ Supprimer")
            LIGNE=$(cat "$ROOT_DIR/memory/long_term_facts.json" "$ROOT_DIR/memory/journal_de_bord.txt" 2>/dev/null | grep -v "^$" | zenity --list --title="🗑️ Supprimer un Souvenir" --text="Choisis la ligne à effacer définitivement :" --column="Mémoire enregistrée" --width=700 --height=450 2>/dev/null)
            if [ -n "$LIGNE" ]; then
                python3 -c '
import sys
target = sys.argv[1]
for p in sys.argv[2:]:
    try:
        lines = open(p, encoding="utf-8", errors="ignore").readlines()
        open(p, "w", encoding="utf-8").writelines([l for l in lines if target not in l])
    except Exception:
        pass
' "$LIGNE" "$ROOT_DIR/memory/long_term_facts.json" "$ROOT_DIR/memory/journal_de_bord.txt"
            fi
            ;;
        *)
            break
            ;;
    esac
done
rm -f "$TMP_VIEW"
