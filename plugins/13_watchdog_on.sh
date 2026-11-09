#!/bin/bash
# MENU_NAME: 🛡️ Watchdog ON
# MENU_DESC: Lancer la sentinelle thermique autonome
pkill -f thermal_watchdog.sh >/dev/null 2>&1
~/tiffany/thermal_watchdog.sh >/dev/null 2>&1 &
zenity --info --title="Tiffany OS -- Sentinelle" --text="🛡️ Sentinelle thermique active, mon ange ! Je surveille tes cœurs en arrière-plan chéri." --timeout=3 2>/dev/null
