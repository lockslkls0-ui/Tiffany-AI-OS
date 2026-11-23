#!/usr/bin/env bash
# TERM_KEY: parametres mobile
# TERM_DESC: URL, PIN et Aide du compagnon mobile
# TERM_ICON: 📱
IP=$(hostname -I | awk "{print \$1}"); PIN=$(cat ~/.config/tiffany/mobile_pin.txt 2>/dev/null || echo 1246)
zenity --info --title="📱 Aide & Config Mobile" --text="Adresse : http://$IP:8486
Code PIN : $PIN

• Top 10 MP3 : clique sur Telechargeur mp3 pro
• Heure / Météo : écris ta question en haut"
