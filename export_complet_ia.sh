#!/usr/bin/env bash
DATE_H=$(date +"%Y-%m-%d_%Hh%M")
BUREAU=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
[ ! -d "$BUREAU" ] && BUREAU="$HOME/Bureau"

DOSSIER="$BUREAU/Export_IA_Tiffany_${DATE_H}_V48.6"
KIT_OUT="$DOSSIER/5_KIT_LANCEMENT_OFFICIEL"
mkdir -p "$DOSSIER" "$KIT_OUT"

F1="$DOSSIER/1_INTEGRALITE_SCRIPTS_ACTUELS.txt"
F2="$DOSSIER/2_HISTORIQUE_EVOLUTION_GIT.txt"
F3="$DOSSIER/3_MEMOIRE_CONFIGURATION_ET_ALIAS.txt"
F4="$DOSSIER/4_OPTIMISATIONS_ET_ERREURS_DIAGNOSTIC.txt"

# Fichier 1 : 100% du code (sans limite de profondeur + bin/espeak-ng + systemd + .desktop)
echo "=== TIFFANY AI-OS V48.6 — INTÉGRALITÉ ABSOLUE DU CODE ($DATE_H) ===" > "$F1"
{
    find "$HOME/tiffany" -not -path '*/.git*' -not -path '*/backup*' -not -path '*/__pycache__*' -not -path '*/vosk-fr*' \
        \( -name "*.sh" -o -name "*.py" -o -name "*.json" -o -name "*.yaml" -o -name "*.md" -o -name "Modelfile" -o -path "*/bin/espeak-ng" \) | sort
    find "$HOME/.config/systemd/user" -name "tiffany-*" 2>/dev/null | sort
    find "$BUREAU" -maxdepth 1 -name "*.desktop" 2>/dev/null | sort
} | while read -r f; do
    [ -f "$f" ] || continue
    echo -e "\n====================================================================" >> "$F1"
    echo "FICHIER : $f | DATE : $DATE_H | VERSION : V48.6" >> "$F1"
    echo -e "====================================================================\n" >> "$F1"
    cat "$f" >> "$F1"
done

# Fichier 2 : Historique Git complet
echo "=== HISTORIQUE COMPLET DU PROJET TIFFANY AI-OS ($DATE_H) ===" > "$F2"
cd "$HOME/tiffany" && git log --stat --pretty=format:"[%ad] %h - %s (%an)" --date=iso >> "$F2" 2>/dev/null || echo "Historique Git non initialisé" >> "$F2"

# Fichier 3 : Mémoires, configurations et dictionnaires
echo "=== MÉMOIRE, ALIAS ET DICTIONNAIRES VOCAUX ($DATE_H) ===" > "$F3"
for cfg in \
    "$HOME/tiffany/config_tiffany.json" \
    "$HOME/tiffany/memory/surnom_utilisateur.txt" \
    "$HOME/tiffany/memory/ambiance_active.txt" \
    "$HOME/tiffany/memory/contexte_matrice.txt" \
    "$HOME/tiffany/memory/long_term_facts.json" \
    "$HOME/tiffany/memory/journal_de_bord.txt" \
    "$HOME/tiffany/memory/connaissances_web.txt" \
    "$HOME/tiffany/dictionnaire_flash.txt" \
    "$HOME/tiffany/variantes_utilisateur.txt" \
    "$HOME/tiffany/actions_terminal/dictionnaire_ia.txt" \
    "$HOME/tiffany/voice/mode_voix.txt"
do
    if [ -f "$cfg" ]; then
        echo -e "\n--- CONTENU DE : $cfg ---\n" >> "$F3"
        cat "$cfg" >> "$F3"
    fi
done

# Fichier 4 : Diagnostic & Logs
echo "=== DIAGNOSTIC, OPTIMISATIONS ET ERREURS ($DATE_H) ===" > "$F4"
python3 "$HOME/tiffany/audit_complet_tiffany.py" | sed 's/\x1b\[[0-9;]*m//g' >> "$F4" 2>/dev/null
echo -e "\n--- DERNIERS LOGS SYSTEMD ---\n" >> "$F4"
journalctl --user -u tiffany-ear.service -u tiffany-watchdog.service -n 30 --no-pager >> "$F4" 2>/dev/null

# 5. Kit de Lancement Officiel complet et à jour
cp -f "$HOME/tiffany/install.sh" "$KIT_OUT/install.sh"
[ -f "$HOME/tiffany/README.md" ] && cp -f "$HOME/tiffany/README.md" "$KIT_OUT/README.md"
[ -f "$BUREAU/tiffany-ai-os_48.6_all.deb" ] && cp -f "$BUREAU/tiffany-ai-os_48.6_all.deb" "$KIT_OUT/"

tar --exclude='.git' --exclude='backup' --exclude='logs/*' --exclude='memory/*' --exclude='*.log' --exclude='__pycache__' \
    -czf "$KIT_OUT/Tiffany-AI-OS-PRO-v48.6.tar.gz" -C "$HOME" tiffany 2>/dev/null || true

cat << 'EOK' > "$KIT_OUT/LISEZMOI_LANCEMENT.txt"
=== 🚀 KIT DE LANCEMENT OFFICIEL — TIFFANY AI-OS V48.6 ===

1. INSTALLATION DEPUIS L'ARCHIVE :
   tar -xzf Tiffany-AI-OS-PRO-v48.6.tar.gz -C ~
   bash ~/tiffany/install.sh

2. INSTALLATION DEPUIS LE PAQUET .DEB (si présent) :
   sudo apt install ./tiffany-ai-os_48.6_all.deb

3. COMMANDES RAPIDES :
   - Panneau graphique : icône "🌹 Panneau Tiffany" sur le Bureau (ou ~/tiffany/tiffany_menu.sh)
   - Console hybride   : taper "tiff" dans un terminal
EOK

"$HOME/tiffany/bin/espeak-ng" "Export intégral et kit de lancement réparés et générés sur ton Bureau, mon ange." >/dev/null 2>&1 &
[ "${TIFF_SILENT_EXPORT:-0}" != "1" ] && zenity --info --title="Tiffany AI-OS V48.6" --text="✅ Export 100 % complet réussi !\n\nDossier créé sur ton Bureau :\nExport_IA_Tiffany_${DATE_H}_V48.6" --width=460 2>/dev/null
