#!/usr/bin/env bash
# MENU_NAME: 💤 Sommeil Total (Tout ON / OFF)
# MENU_DESC: Endormir ou réveiller 100% des services de Tiffany (0% CPU/RAM)
FLAG="$HOME/.config/tiffany/sommeil_total"

if [ ! -f "$FLAG" ]; then
    touch "$FLAG" "$HOME/.config/tiffany/oreille_off"
    systemctl --user stop tiffany-ear.service tiffany-watchdog.service tiffany-diary.timer 2>/dev/null || true
    pkill -9 -f "03_moteur_ecoute|thermal_watchdog|tiffany_core|piper|arecord" 2>/dev/null || true
    sudo systemctl stop ollama 2>/dev/null || sudo snap stop ollama 2>/dev/null || true
    "$HOME/tiffany/bin/espeak-ng" "Mode sommeil total activé. Je m'endors complètement, mon ange." >/dev/null 2>&1 &
    zenity --info --title="💤 Tiffany Endormie" --text="✅ Mode Sommeil Total activé !\n\n• Oreille vocale : COUPÉE\n• Sentinelle thermique : COUPÉE\n• Archiviste mémoire : EN PAUSE\n• Moteur IA Ollama : ARRÊTÉ\n\nConsommation CPU/RAM : 0 %" --width=360 2>/dev/null
else
    rm -f "$FLAG" "$HOME/.config/tiffany/oreille_off"
    sudo systemctl start ollama 2>/dev/null || sudo snap start ollama 2>/dev/null || true
    systemctl --user start tiffany-watchdog.service tiffany-ear.service tiffany-diary.timer 2>/dev/null || true
    "$HOME/tiffany/bin/espeak-ng" "Bonjour mon ange ! Tous mes sens et mes services sont réveillés." >/dev/null 2>&1 &
    zenity --info --title="⚡ Tiffany Réveillée" --text="✅ Tous les systèmes de Tiffany sont de nouveau actifs !" --width=340 --timeout=3 2>/dev/null
fi
