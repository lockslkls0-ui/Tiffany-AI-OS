#!/usr/bin/env bash
# MENU_NAME: 👂 Oreille Vocale (ON / OFF)
# MENU_DESC: Basculer l écoute continue ON ou OFF (mémorisé)
FLAG="$HOME/.config/tiffany/oreille_off"
if [ -f "$FLAG" ]; then
    rm -f "$FLAG"
    systemctl --user enable --now tiffany-ear.service >/dev/null 2>&1 || true
    nohup flock -n /tmp/tiffany_ear.lock bash "$HOME/tiffany/tiffany_ear_daemon.sh" >/dev/null 2>&1 &
    notify-send -u normal "👂 Oreille Vocale ACTIVÉE" "Écoute continue en boucle relancée !"
else
    touch "$FLAG"
    systemctl --user stop tiffany-ear.service >/dev/null 2>&1 || true
    pkill -9 -f "03_moteur_ecoute|tiffany_ear_daemon|tiffany_ear_worker|arecord" 2>/dev/null || true
    notify-send -u normal "🔇 Oreille Vocale COUPÉE" "Micro et Python arrêtés jusqu au prochain clic ON."
fi
