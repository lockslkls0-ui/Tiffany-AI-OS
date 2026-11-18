#!/usr/bin/env bash
# MENU_NAME: 💾 Sauvegarder la Matrice
# MENU_DESC: Sauvegarder l'intégralité du système Tiffany et les rapports matériels

BACKUP_DIR="$HOME/tiffany_sauvegardes"
mkdir -p "$BACKUP_DIR"
NOM_BACKUP="matrice_complete_$(date +%Y%m%d_%H%M%S)"
SURNOM=$(cat "$HOME/tiffany/memory/surnom_utilisateur.txt" 2>/dev/null | xargs)
IS_CREATOR=0
[[ "$SURNOM" == "lockss" || "$SURNOM" == "lockslkls" || -f "$HOME/.config/tiffany/pro_license.key" ]] && IS_CREATOR=1

(
    echo "20"
    echo "# 📊 Diagnostic matériel et santé disque SMART..."
    sudo -n lshw -short > "$HOME/tiffany/logs/fiche_technique.txt" 2>/dev/null || true
    sudo -n smartctl -A /dev/sda > "$HOME/tiffany/logs/sante_disque.txt" 2>/dev/null || true

    echo "50"
    echo "# 🛡️ Création de l'archive complète de la matrice..."
    ARCHIVE_PATH="$BACKUP_DIR/${NOM_BACKUP}.tar.gz"
    tar -czf "$ARCHIVE_PATH" \
        -C "$HOME" tiffany \
        $( [ -f "$HOME/.tiffany_radios.txt" ] && echo ".tiffany_radios.txt" ) \
        $( [ -f "$HOME/.catalogue_geant.txt" ] && echo ".catalogue_geant.txt" ) 2>/dev/null

    if [ "$IS_CREATOR" -eq 1 ]; then
        echo "80"
        echo "# 📦 Mode Créateur : Génération Export IA + Kit + Copie de la Matrice dans le même dossier..."
        TIFF_SILENT_EXPORT=1 bash "$HOME/tiffany/export_complet_ia.sh" >/dev/null 2>&1 || true

        BUREAU_BASE="$HOME/Bureau"
        [ ! -d "$BUREAU_BASE" ] && BUREAU_BASE="$HOME/Desktop"
        DERNIER_EXPORT=$(ls -td "$BUREAU_BASE"/Export_IA_Tiffany_* 2>/dev/null | head -n 1)

        if [ -n "$DERNIER_EXPORT" ] && [ -d "$DERNIER_EXPORT" ]; then
            cp -f "$ARCHIVE_PATH" "$DERNIER_EXPORT/"
        fi
    fi

    echo "100"
    echo "# ✅ Sauvegarde intégrale terminée !"
) | zenity --progress --title="💾 Super-Backup Tiffany AI-OS" --text="Initialisation..." --auto-close --width=460 2>/dev/null

"$HOME/tiffany/bin/espeak-ng" "Sauvegarde de la matrice et export complet terminés dans le même dossier, mon ange." >/dev/null 2>&1 &

if [ "$IS_CREATOR" -eq 1 ]; then
    BUREAU_BASE="$HOME/Bureau"
    [ ! -d "$BUREAU_BASE" ] && BUREAU_BASE="$HOME/Desktop"
    DERNIER_EXPORT=$(ls -td "$BUREAU_BASE"/Export_IA_Tiffany_* 2>/dev/null | head -n 1)
    zenity --info --title="✅ Sauvegarde & Export Unifiés" \
        --text="Tout est rassemblé dans un seul dossier sur ton Bureau :\n👉 $(basename "$DERNIER_EXPORT")\n\n• Les 4 fichiers d'Export Complet IA\n• Le dossier 5_KIT_LANCEMENT_OFFICIEL\n• L'archive complète ${NOM_BACKUP}.tar.gz" \
        --width=480 --timeout=6 2>/dev/null
    [ -n "$DERNIER_EXPORT" ] && nemo "$DERNIER_EXPORT" >/dev/null 2>&1 &
else
    zenity --info --title="✅ Sauvegarde Réussie" \
        --text="Système et mémoire sauvegardés dans :\n~/tiffany_sauvegardes/${NOM_BACKUP}.tar.gz" \
        --width=400 --timeout=5 2>/dev/null
fi
