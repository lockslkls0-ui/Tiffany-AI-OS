#!/usr/bin/env bash
# MENU_NAME: 📚 Inventaire & Stats Alias
# MENU_DESC: Lister les 235 alias actifs et calculer l indice de fluidite
gnome-terminal --title="📚 Inventaire Alias Tiffany AI-OS" -- bash -c "python3 ~/tiffany/inventaire_alias.py | less -R"
