#!/bin/bash
# MENU_NAME: 🖥️ Détails Système & Noyau
# MENU_DESC: Scanner matériel lshw complet et logs d'intégrité
gnome-terminal --title="📊 Analyse Matérielle en Direct" -- bash -c "sudo lshw -short; echo -e '\n\n📊 LOGS ET ERREURS SYSTÈME RÉCENTES :\n'; sudo dmesg | tail -n 15; echo -e '\n[Appuie sur Entrée pour fermer]'; read"
