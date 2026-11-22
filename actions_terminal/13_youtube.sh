#!/usr/bin/env bash
# TERM_KEY: youtube
# TERM_DESC: Ouvrir YouTube dans Google Chrome
# TERM_ICON: 🌐
export DISPLAY="${DISPLAY:-:0}"
nohup google-chrome --new-tab "https://www.youtube.com" >/dev/null 2>&1 &
sleep 1 && wmctrl -a "Google Chrome" >/dev/null 2>&1 || true
