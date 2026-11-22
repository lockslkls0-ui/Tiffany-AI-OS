#!/usr/bin/env bash
CMD=$(zenity --entry --title="🌹 Tiffany — Commande Rapide" --text="Parle ou donne un ordre à Tiffany :" --width=460 2>/dev/null)
[ -n "$CMD" ] && bash "$HOME/tiffany/tiffany_actions.sh" "$CMD"
