#!/bin/bash
# MENU_NAME: 💾 Sauvegarder la Matrice
# MENU_DESC: Générer la fiche technique, l'état des disques et archiver l'ADN chéri
mkdir -p "$HOME/tiffany_sauvegardes"
NOM_BACKUP="matrice_complete_$(date +%Y%m%d_%H%M%S)"
(
    echo "# 📊 Diagnostic de la fiche technique (lshw)..."; sleep 0.5
    sudo lshw -short > "$HOME/tiffany/logs/fiche_technique.txt" 2>/dev/null
    
    echo "# 🔍 Sondage de l'état de santé du disque sda (SMART)..."; sleep 0.5
    sudo smartctl -A /dev/sda > "$HOME/tiffany/logs/sante_disque.txt" 2>/dev/null
    
    echo "# 🛡️ Archivage global de l'ADN et des rapports..."; sleep 0.5
    tar -czf "$HOME/tiffany_sauvegardes/${NOM_BACKUP}.tar.gz" -C "$HOME" tiffany .tiffany_radios.txt .catalogue_geant.txt 2>/dev/null
    echo "100"
) | zenity --progress --title="Tiffany OS -- Super-Backup" --text="Initialisation..." --auto-close --width=450 2>/dev/null
zenity --info --title="Tiffany OS" --text="✅ Restauration et sauvegarde accomplies mon ange !\n\n📦 Rapports techniques injectés dans l'archive :\n${NOM_BACKUP}.tar.gz" --width=400 --timeout=5 2>/dev/null
