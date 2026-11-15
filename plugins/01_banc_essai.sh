#!/usr/bin/env bash
# MENU_NAME: 🔬 Banc d'Essai Intégral
# MENU_DESC: Analyser 100 % des scripts, modèles vocaux et sentinelles (Vert/Rouge)
gnome-terminal --title="🔬 Banc d Essai Tiffany AI-OS" -- bash -c "python3 ~/tiffany/audit_complet_tiffany.py; echo; read -p 'Appuie sur Entrée pour fermer...'"
