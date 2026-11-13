#!/usr/bin/env bash
# MENU_NAME: 🧼 Purge Éclair & Relance
# MENU_DESC: Purger le cache RAM et réveiller Ollama
pkexec bash -c "sync && echo 3 > /proc/sys/vm/drop_caches && systemctl restart ollama" >/dev/null 2>&1
notify-send -u low -t 3000 -i "user-trash" "🧼 Purge RAM" "Mémoire cache libérée et moteur IA réaligné !"
