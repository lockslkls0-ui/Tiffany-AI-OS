#!/usr/bin/env bash
# MENU_NAME: 🛡️ Armure & Auto-Guérison
# MENU_DESC: Nettoyer les verrous, relancer les services et restaurer le code sain si besoin
rm -f /tmp/tiffany_menu.lock /tmp/tiffany_panneau_moving.lock /tmp/tiffany_last_act.lock
systemctl --user daemon-reload
systemctl --user restart tiffany-watchdog.service tiffany-diary.timer
[ ! -f ~/.config/tiffany/oreille_off ] && systemctl --user restart tiffany-ear.service
zenity --question --title="🛡️ Armure Tiffany AI-OS" --text="✅ Verrous nettoyés et services relancés !\n\nVeux-tu aussi restaurer les scripts d'origine (version stable scellée) ?" --width=440 2>/dev/null
if [ $? -eq 0 ]; then
    cd ~/tiffany && git checkout v48.6-armure -- *.sh *.py actions_terminal/ plugins/ ear_modules/ bin/
    chmod +x ~/tiffany/*.sh ~/tiffany/actions_terminal/*.sh ~/tiffany/plugins/*.sh ~/tiffany/bin/*
    zenity --info --title="🛡️ Restauration Terminée" --text="🏆 Tous les scripts ont été restaurés à leur état d'usine parfait !" --width=380 2>/dev/null
fi
