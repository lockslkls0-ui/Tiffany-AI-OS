#!/bin/bash
# MENU_NAME: 🎵 Allumer Rhythmbox (Playlist)
# MENU_DESC: Forcer le chargement et la lecture de toute la musique locale
pkill -9 -x "mpv" >/dev/null 2>&1
pkill -9 -x "vlc" >/dev/null 2>&1
if ! pgrep -x "rhythmbox" >/dev/null; then
    rhythmbox >/dev/null 2>&1 &
    sleep 4
fi
rhythmbox-client --stop >/dev/null 2>&1
rhythmbox-client --clear-queue >/dev/null 2>&1
rhythmbox-client --shuffle >/dev/null 2>&1
rhythmbox-client --enqueue "$HOME/Musique" >/dev/null 2>&1
sleep 1.5
rhythmbox-client --next >/dev/null 2>&1
rhythmbox-client --play >/dev/null 2>&1
