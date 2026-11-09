#!/bin/bash
# MENU_NAME: 🧼 Vider la Corbeille
# MENU_DESC: Purger la poubelle instantanément
~/tiffany/tiffany_utilitaire.sh "corbeille"
zenity --info --text="🧼 Poubelle purgée !" --timeout=2 2>/dev/null
