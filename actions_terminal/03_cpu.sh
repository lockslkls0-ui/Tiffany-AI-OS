#!/bin/bash
# TERM_KEY: cpu
# TERM_DESC: Thermique et cadence
# TERM_ICON: 🌡️
gnome-terminal --title="🌡️ CPU" -- bash -c "$HOME/tiffany/tiffany_utilitaire.sh etat_cpu; read"
