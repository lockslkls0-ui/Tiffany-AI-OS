#!/bin/bash
# MENU_NAME: ⏭️ Morceau Suivant
# MENU_DESC: Passer instantanément à la chanson suivante de ta playlist
rhythmbox-client --no-start --next >/dev/null 2>&1 || rhythmbox-client --next >/dev/null 2>&1
