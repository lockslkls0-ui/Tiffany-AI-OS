#!/usr/bin/env bash
# MENU_NAME: 📝 Mémoire & Journaux de Tiffany
# MENU_DESC: Livre de bord intégral daté et expliqué en français (Souvenirs, Web-IA, Web, Dojo, Bugs, Analyses, Sessions)

ROOT_DIR="$HOME/tiffany"
TMP_VIEW="/tmp/tiffany_memoire_integrale.txt"

while true; do
    {
        echo "=========================================================================="
        echo " 🧠 ARCHIVE INTÉGRALE & CONSCIENCE TOTALE DE TIFFANY AI-OS (100% COMPLET)"
        echo " 📅 Généré en direct le : $(date '+%d/%m/%Y à %H:%M:%S')"
        echo "=========================================================================="
        echo " 👑 Créateur officiel  : lockslkls"
        echo " 👤 Utilisateur actuel : $(cat "$ROOT_DIR/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")"
        echo " 🎭 Ambiance active    : $(cat "$ROOT_DIR/memory/ambiance_active.txt" 2>/dev/null || echo "complice")"
        echo ""

        echo "=========================================================================="
        echo " 1. 📌 FAITS & SOUVENIRS GRAVÉS À LONG TERME (Datés)"
        echo "=========================================================================="
        if [ -s "$ROOT_DIR/memory/long_term_facts.json" ]; then
            cat "$ROOT_DIR/memory/long_term_facts.json"
        else
            echo "Aucun fait gravé."
        fi
        echo ""

        echo "=========================================================================="
        echo " 2. 🌍 INTÉGRALITÉ DES FICHES WEB-IA & PAGES WEB ASPIRÉES (100% du contenu)"
        echo "=========================================================================="
        if [ -s "$ROOT_DIR/memory/connaissances_web.txt" ]; then
            echo "--- 📚 Base de connaissances Web mémorisée ---"
            cat "$ROOT_DIR/memory/connaissances_web.txt"
            echo ""
        fi
        find "$HOME" -maxdepth 3 \( -iname "*web*ia*" -o -iname "*dossier*web*" -o -path "*/tiffany/connaissances/*" \) 2>/dev/null | sort -u | while read -r item; do
            if [ -d "$item" ]; then
                DATE_D=$(date -r "$item" '+%d/%m/%Y à %H:%M' 2>/dev/null)
                echo -e "\n--- 📂 DOSSIER WEB-IA : $(basename "$item") [Créé le $DATE_D] ---"
                find "$item" -type f \( -name "*.txt" -o -name "*.md" \) | sort | while read -r f; do
                    echo "📄 Fichier : $(basename "$f")"
                    cat "$f" 2>/dev/null
                    echo ""
                done
            elif [ -f "$item" ] && [[ "$item" =~ \.(txt|md)$ ]]; then
                DATE_F=$(date -r "$item" '+%d/%m/%Y à %H:%M' 2>/dev/null)
                echo -e "\n--- 📄 FICHIER WEB : $(basename "$item") [Date : $DATE_F] ---"
                cat "$item" 2>/dev/null
                echo ""
            fi
        done

        echo "=========================================================================="
        echo " 3. 🥋 EXPLOITS DU DOJO, COMMANDES APPRISES & VARIANTES (Auto-évolution)"
        echo "=========================================================================="
        echo "--- ⚡ Commandes apprises (dictionnaire_ia.txt) ---"
        [ -s "$ROOT_DIR/dictionnaire_ia.txt" ] && cat "$ROOT_DIR/dictionnaire_ia.txt" || echo "Aucune commande réflexe."
        echo "--- 🌍 Variantes & Traductions personnalisées (variantes_utilisateur.txt) ---"
        [ -s "$ROOT_DIR/variantes_utilisateur.txt" ] && cat "$ROOT_DIR/variantes_utilisateur.txt" || echo "Aucune variante."
        for s in "$ROOT_DIR/dojo/"*.sh; do
            [ -f "$s" ] || continue
            DATE_S=$(date -r "$s" '+%d/%m/%Y à %H:%M' 2>/dev/null)
            echo -e "\n--- 🥋 Script Dojo : $(basename "$s") [Forgé le $DATE_S] ---"
            cat "$s"
        done
        echo ""

        echo "=========================================================================="
        echo " 4. 🩺 ANALYSES MATÉRIELLES, SANTÉ DISQUE SMART & BUGS TRADUITS EN FRANÇAIS"
        echo "=========================================================================="
        if [ -s "$ROOT_DIR/logs/sante_disque.txt" ]; then
            DATE_SM=$(date -r "$ROOT_DIR/logs/sante_disque.txt" '+%d/%m/%Y à %H:%M' 2>/dev/null)
            echo "--- 💾 Relevé SMART Disque Dur [Date : $DATE_SM] ---"
            grep -E "Power_On_Hours|Reallocated_Sector|Temperature_Celsius|UDMA_CRC" "$ROOT_DIR/logs/sante_disque.txt"
        fi
        if [ -s "$ROOT_DIR/logs/audit_mistral.log" ]; then
            echo "--- 🩺 Historique des Audits Docteur Mistral ---"
            cat "$ROOT_DIR/logs/audit_mistral.log"
        fi
        if [ -s "$ROOT_DIR/logs/thermique.log" ]; then
            echo "--- 🌡️ Historique Thermique & Régulation CPU (Watchdog) ---"
            cat "$ROOT_DIR/logs/thermique.log"
        fi
        echo "--- 🛠️ Derniers Bugs & Événements Système Datés et Expliqués en Français ---"
        python3 - << 'PYEOF'
import subprocess, re

logs = subprocess.getoutput("journalctl -p 3 -n 60 --no-pager -q 2>/dev/null").strip().splitlines()
traductions = [
    (r"systemd-coredump.*Process.*\\(([^)]+)\\).*dumped core", "Plantage ponctuel du programme « \\1 » (rapport nettoyé automatiquement par Linux)."),
    (r"I/O error.*sda|blk_update_request", "Erreur matérielle de lecture/écriture sur le disque dur sda (secteur fatigué ou câble SATA)."),
    (r"Out of memory|Killed process", "Saturation mémoire vive : Linux a fermé un logiciel gourmand pour éviter le gel."),
    (r"i915|drm.*ERROR", "Micro-erreur d'affichage de la puce graphique Intel (sans gravité)."),
    (r"ACPI Error|ACPI BIOS Error|AE_NOT_FOUND", "Erreur mineure du BIOS ACPI au démarrage (classique sur Toshiba, sans danger)."),
    (r"notify-send.*trap int3", "Une bulle de notification graphique a été interrompue lors d'un pic de charge."),
    (r"systemd-journald.*killed", "Le journal système a été purgé automatiquement après une saturation."),
    (r"iwlwifi|ath9k|wlan|NetworkManager.*error", "Instabilité temporaire détectée sur la carte Wi-Fi."),
    (r"ollama.*timeout|llama-server", "Le moteur IA local a mis trop de temps à répondre ou a été interrompu.")
]
vus = set()
for ligne in logs:
    m_date = re.match(r'^([a-zA-Zéû]+\\.\\s+\\d+\\s+[0-9:]+)\\s+\\S+\\s+(.*)$', ligne)
    if not m_date:
        continue
    horodate, msg = m_date.group(1), m_date.group(2).strip()
    if not msg or re.match(r'^(#\\d+|Stack trace|ELF object|Module lib)', msg):
        continue
    explic = None
    for motif, fr in traductions:
        m = re.search(motif, msg, re.I)
        if m:
            explic = m.expand(fr) if "\\\\1" in fr else fr
            break
    if not explic:
        explic = f"Événement technique : {msg[:100]}"
    cle = f"{horodate[:12]}|{explic}"
    if cle not in vus:
        vus.add(cle)
        print(f"  [{horodate}] ⚠️ {explic}")
if not vus:
    print("  ✅ Aucune erreur critique dans les journaux système récents.")
PYEOF
        echo ""

        echo "=========================================================================="
        echo " 5. 📖 JOURNAL DE BORD SYNTHÉTIQUE DES SESSIONS (journal_de_bord.txt)"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/memory/journal_de_bord.txt" ] && cat "$ROOT_DIR/memory/journal_de_bord.txt" || echo "Aucune session archivée."
        echo ""

        echo "=========================================================================="
        echo " 6. 💬 INTÉGRALITÉ DES ÉCHANGES, VOIX & ANALYSES EN DIRECT (session_raw.txt)"
        echo "=========================================================================="
        [ -s "$ROOT_DIR/logs/session_raw.txt" ] && cat "$ROOT_DIR/logs/session_raw.txt" || echo "Aucun échange enregistré."
    } | tr -d '\000' > "$TMP_VIEW"

    CHOIX=$(zenity --text-info --title="🧠 Mémoire Intégrale Datée & Expliquée — Tiffany AI-OS" \
        --filename="$TMP_VIEW" \
        --extra-button="➕ Ajouter" \
        --extra-button="✏️ Modifier" \
        --extra-button="🗑️ Supprimer" \
        --width=860 --height=640 2>/dev/null)

    case "$CHOIX" in
        "➕ Ajouter")
            NOUVEAU=$(zenity --entry --title="➕ Graver un Souvenir" --text="Écris le souvenir à graver avec la date d'aujourd'hui :" --width=520 2>/dev/null)
            [ -n "$NOUVEAU" ] && echo "- [$(date '+%d/%m/%Y %H:%M')] $NOUVEAU" >> "$ROOT_DIR/memory/long_term_facts.json"
            ;;
        "✏️ Modifier")
            LIGNE=$(cat "$ROOT_DIR/memory/long_term_facts.json" "$ROOT_DIR/memory/journal_de_bord.txt" 2>/dev/null | grep -v "^$" | zenity --list --title="✏️ Modifier un Souvenir" --text="Sélectionne la ligne à modifier :" --column="Mémoire enregistrée" --width=740 --height=460 2>/dev/null)
            if [ -n "$LIGNE" ]; then
                MODIF=$(zenity --entry --title="✏️ Modifier" --text="Modifie le texte :" --entry-text="$LIGNE" --width=580 2>/dev/null)
                if [ -n "$MODIF" ]; then
                    python3 -c '
import sys
old, new = sys.argv.__getitem__(1), sys.argv.__getitem__(2)
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
            LIGNE=$(cat "$ROOT_DIR/memory/long_term_facts.json" "$ROOT_DIR/memory/journal_de_bord.txt" 2>/dev/null | grep -v "^$" | zenity --list --title="🗑️ Supprimer un Souvenir" --text="Sélectionne la ligne à effacer définitivement :" --column="Mémoire enregistrée" --width=740 --height=460 2>/dev/null)
            if [ -n "$LIGNE" ]; then
                python3 -c '
import sys
target = sys.argv.__getitem__(1)
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
