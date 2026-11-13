#!/usr/bin/env bash
# MENU_NAME: 🧬 Instinct Étendu (Capteurs)
# MENU_DESC: Usure batterie, périphériques USB, Bluetooth et capteurs complets

BAT_INFO=$(upower -i $(upower -e | grep -i battery | head -n 1) 2>/dev/null | grep -E "state|percentage|capacity|energy-full:" | sed 's/^[ \t]*//' | tr '\n' ' | ')
[ -z "$BAT_INFO" ] && BAT_INFO="Secteur / Batterie non détectée"

USB_LIST=$(lsusb 2>/dev/null | awk -F': ' '{print "• " $2}' | head -n 6)
BT_STATUS=$(rfkill list bluetooth 2>/dev/null | grep -q "Soft blocked: yes" && echo "Désactivé" || echo "Actif")
BT_DEV=$(bluetoothctl devices Connected 2>/dev/null | cut -d' ' -f3-)
[ -z "$BT_DEV" ] && BT_DEV="Aucun appareil connecté"

zenity --info --title="🧬 Instinct Matériel Étendu" \
    --text="🔋 Énergie & Usure Batterie :\n$BAT_INFO\n\n📶 Bluetooth ($BT_STATUS) : $BT_DEV\n\n🔌 Périphériques USB actifs :\n$USB_LIST" \
    --width=520 2>/dev/null
