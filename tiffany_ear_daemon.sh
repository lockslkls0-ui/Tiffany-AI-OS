#!/usr/bin/env bash
export PATH="$HOME/tiffany/bin:$PATH"
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
bash "$HOME/tiffany/ear_modules/01_audio_micro.sh"
python3 "$HOME/tiffany/ear_modules/03_moteur_ecoute.py"
