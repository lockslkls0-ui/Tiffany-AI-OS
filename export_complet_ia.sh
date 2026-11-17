#!/bin/bash
DATE_H=$(date +"%Y-%m-%d_%Hh%M")
DOSSIER="$HOME/Bureau/Export_IA_Tiffany_${DATE_H}_V48.6"
mkdir -p "$DOSSIER"

F1="$DOSSIER/1_INTEGRALITE_SCRIPTS_ACTUELS.txt"
F2="$DOSSIER/2_HISTORIQUE_EVOLUTION_GIT.txt"
F3="$DOSSIER/3_MEMOIRE_CONFIGURATION_ET_ALIAS.txt"
F4="$DOSSIER/4_OPTIMISATIONS_ET_ERREURS_DIAGNOSTIC.txt"

# Fichier 1 : Tous les scripts Bash et Python actuels
echo "=== TIFFANY AI-OS V48.6 — INTÉGRALITÉ DES SCRIPTS ACTUELS ($DATE_H) ===" > "$F1"
find "$HOME/tiffany" -maxdepth 3 \( -name "*.sh" -o -name "*.py" \) | sort | while read -r f; do
    echo -e "\n====================================================================" >> "$F1"
    echo "FICHIER : $f | DATE : $DATE_H | VERSION : V48.6" >> "$F1"
    echo -e "====================================================================\n" >> "$F1"
    cat "$f" >> "$F1"
done

# Fichier 2 : Historique complet depuis le début
echo "=== HISTORIQUE COMPLET DU PROJET TIFFANY AI-OS ($DATE_H) ===" > "$F2"
cd "$HOME/tiffany" && git log --stat --pretty=format:"[%ad] %h - %s (%an)" --date=iso >> "$F2" 2>/dev/null || echo "Historique Git non initialisé" >> "$F2"

# Fichier 3 : Mémoire, Alias et Dictionnaires
echo "=== MÉMOIRE, ALIAS ET DICTIONNAIRES VOCAUX ($DATE_H) ===" > "$F3"
for cfg in "$HOME/tiffany/memory/long_term_facts.json" "$HOME/tiffany/memory/journal_de_bord.txt" "$HOME/tiffany/dictionnaire_flash.txt" "$HOME/tiffany/variantes_utilisateur.txt" "$HOME/tiffany/actions_terminal/dictionnaire_ia.txt"; do
    if [ -f "$cfg" ]; then
        echo -e "\n--- CONTENU DE : $cfg ---\n" >> "$F3"
        cat "$cfg" >> "$F3"
    fi
done

# Fichier 4 : Optimisations, Audit 51/51 et Erreurs Système
echo "=== DIAGNOSTIC, OPTIMISATIONS ET ERREURS ($DATE_H) ===" > "$F4"
python3 "$HOME/tiffany/audit_complet_tiffany.py" | sed 's/\x1b\[[0-9;]*m//g' >> "$F4" 2>/dev/null
echo -e "\n--- DERNIÈRES ERREURS SYSTÈME (JOURNALCTL) ---\n" >> "$F4"
journalctl --user -u tiffany-ear.service -u tiffany-watchdog.service -n 30 --no-pager >> "$F4" 2>/dev/null

# Notification vocale avec la belle voix HD
[ -x "$HOME/tiffany/voix_hd.sh" ] && "$HOME/tiffany/voix_hd.sh" "Export complet terminé mon ange. Les 4 fichiers pour ton intelligence artificielle sont prêts sur ton Bureau." &
zenity --info --title="Tiffany AI-OS V48.6" --text="✅ Export complet réussi !\n\nDossier créé sur ton Bureau :\nExport_IA_Tiffany_${DATE_H}_V48.6\n\nContient les 4 fichiers complets prêts à être partagés." 2>/dev/null
