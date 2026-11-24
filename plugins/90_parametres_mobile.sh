#!/usr/bin/env bash
# MENU_NAME: 📱 Paramètres & Aide Mobile (PRO)
# MENU_DESC: Afficher URL Wi-Fi, Code PIN et guide mobile
# TERM_KEY: parametres mobile
if [ ! -s "$HOME/.config/tiffany/pro_license_disabled_launch" ]; then
    "$HOME/tiffany/bin/espeak-ng" "La télécommande mobile fait partie de l'édition Pro." >/dev/null 2>&1 &
    zenity --question --title="💎 Option Édition PRO" --text="📱 La télécommande Compagnon Mobile nécessite l'Édition PRO.\nVoulez-vous entrer votre clé d'activation maintenant ?" --width=440 2>/dev/null && bash "$HOME/tiffany/plugins/00c_activer_pro.sh"
    exit 0
fi
IP=$(hostname -I | awk "{print \$1}")
PIN=$(cat ~/.config/tiffany/mobile_pin.txt 2>/dev/null || echo 1246)
zenity --info --title="📱 Compagnon Mobile Tiffany PRO" --text="✅ Édition PRO Active\n\nAdresse Wi-Fi : http://$IP:8486\nCode PIN : $PIN" --width=400
