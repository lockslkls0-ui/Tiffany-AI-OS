#!/usr/bin/env bash
# MENU_NAME: 🚨 Arrêt d'Urgence CPU
# MENU_DESC: Tuer les boucles IA/vocales bloquées et calmer le processeur

pkill -9 -f "piper" 2>/dev/null || true
pkill -9 -f "tiffany_ear_daemon" 2>/dev/null || true
pkill -9 -f "vosk" 2>/dev/null || true
pkill -9 -f "llama-server" 2>/dev/null || true
pkill -9 -f "llama-runner" 2>/dev/null || true
pkill -x "espeak-ng" 2>/dev/null || true
pkill -x "aplay" 2>/dev/null || true

sudo systemctl restart ollama 2>/dev/null || true
sync

TOP_PROC=$(ps -eo pcpu,comm --sort=-pcpu | head -n 4 | tail -n 3)
/usr/bin/espeak-ng -v fr+f5 -s 145 -p 85 "Arrêt d'urgence effectué. Le processeur est libéré." >/dev/null 2>&1 &
zenity --info --title="🚨 URGENCE CPU EXÉCUTÉE" \
    --text="✅ Toutes les boucles IA et vocales bloquées ont été stoppées.\n\nTop 3 processus actuels :\n$TOP_PROC" \
    --width=360 2>/dev/null
