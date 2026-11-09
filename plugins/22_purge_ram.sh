#!/bin/bash
# MENU_NAME: 🧼 Purge Éclair \& Relance
# MENU_DESC: Purger la RAM et réveiller Ollama
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1
sudo systemctl restart ollama >/dev/null 2>&1
zenity --info --text="✅ Matrice réalignée, mon ange !" --timeout=2 2>/dev/null
