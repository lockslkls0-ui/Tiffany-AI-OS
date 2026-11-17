#!/usr/bin/env bash
# MENU_NAME: 🚨 Arrêt d'Urgence CPU
# MENU_DESC: Stopper uniquement les boucles IA bloquées (préserve sentinelles & boost)
pkill -9 -f "piper" 2>/dev/null || true
pkill -9 -f "03_moteur_ecoute|tiffany_ear_worker|aiguilleur|assimiler|tiffany_core.py" 2>/dev/null || true
pkill -9 -f "llama-server" 2>/dev/null || true
pkill -9 -f "curl.*11434" 2>/dev/null || true
pkill -x "aplay" 2>/dev/null || true
sudo systemctl restart ollama 2>/dev/null || true
TOP_PROC=$(ps -eo pcpu,comm --sort=-pcpu | head -n 4 | tail -n 3)
espeak-ng -v fr+f5 -s 145 -p 48 "Boucles IA libérées. Vos sentinelles restent actives." >/dev/null 2>&1 &
zenity --info --title="🚨 URGENCE CPU EXÉCUTÉE" --text="✅ Boucles IA bloquées stoppées (Sentinelles & Boost intacts).\n\nTop 3 processus actuels :\n$TOP_PROC" --width=360 2>/dev/null
