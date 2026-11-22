#!/usr/bin/env bash
[ -f "$HOME/.config/tiffany/oreille_off" ] && exit 0
for pid in $(pgrep -f "03_moteur_ecoute.py"); do kill -9 "$pid" 2>/dev/null || true; done
rm -f /tmp/tiffany_ear.lock
export PATH="$HOME/tiffany/bin:$PATH"
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
bash "$HOME/tiffany/ear_modules/01_audio_micro.sh"
exec python3 "$HOME/tiffany/ear_modules/03_moteur_ecoute.py"
