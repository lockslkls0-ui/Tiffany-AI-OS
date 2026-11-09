#!/bin/bash
# MENU_NAME: 🛡️ Stabiliser Chrome (120%)
# MENU_DESC: Brider Chrome pour éviter les surchauffes
pkill -f "cpulimit -e chrome" >/dev/null 2>&1
sudo cpulimit -e chrome -l 120 >/dev/null 2>&1 &
zenity --info --text="🛡️ Stabilisateur enclenché mon ange !" --timeout=2 2>/dev/null
