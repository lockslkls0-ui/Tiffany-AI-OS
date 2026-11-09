#!/bin/bash
# MENU_NAME: 💤 Éteindre le Toshiba
# MENU_DESC: Lancer le rapport diary_agent et éteindre proprement le PC
pkill -f tiffany_watchdog.sh >/dev/null 2>&1
pkill -f thermal_watchdog.sh >/dev/null 2>&1
if [ -f "$HOME/tiffany/agents/diary_agent.py" ]; then python3 "$HOME/tiffany/agents/diary_agent.py"; fi
rhythmbox-client --quit >/dev/null 2>&1
sleep 1
systemctl poweroff || poweroff
