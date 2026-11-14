#!/bin/bash
# MENU_NAME: ⏯️ Play / Pause Rhythmbox
# MENU_DESC: Mettre en pause ou relancer la lecture de Rhythmbox
rhythmbox-client --no-start --play-pause >/dev/null 2>&1 || rhythmbox-client --play >/dev/null 2>&1
