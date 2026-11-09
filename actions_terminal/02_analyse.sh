#!/bin/bash
# TERM_KEY: analyse
# TERM_DESC: Scan matériel lshw et logs
# TERM_ICON: 📊
gnome-terminal --title="📊 Analyse" -- bash -c "sudo lshw -short; echo -e \"\
📊 LOGS :\
\"; sudo dmesg | tail -n 15; read"
