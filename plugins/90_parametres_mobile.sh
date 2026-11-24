#!/usr/bin/env bash
# MENU_NAME: 📱 Paramètres & Aide Mobile
# MENU_DESC: Afficher URL Wi-Fi, Code PIN et guide mobile
# TERM_KEY: parametres mobile
IP=$(hostname -I | awk "{print \$1}"); PIN=$(cat ~/.config/tiffany/mobile_pin.txt 2>/dev/null || echo 1246)
zenity --info --title="📱 Compagnon Mobile Tiffany" --text="Adresse : http://$IP:8486
Code PIN : $PIN" --width=400
