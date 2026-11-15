#!/usr/bin/env bash
[ -f "$HOME/.config/tiffany/oreille_off" ] && exit 0
export PATH="$HOME/tiffany/bin:$PATH"
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
bash "$HOME/tiffany/ear_modules/01_audio_micro.sh"
exec nice -n 10 python3 "$HOME/tiffany/ear_modules/03_moteur_ecoute.py"
