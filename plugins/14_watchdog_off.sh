#!/bin/bash
# MENU_NAME: ⚠️ Watchdog OFF
# MENU_DESC: Arrêter la surveillance automatique
pkill -f thermal_watchdog.sh >/dev/null 2>&1
