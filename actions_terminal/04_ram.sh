#!/usr/bin/env bash
# TERM_KEY: ram
# TERM_DESC: Purge du cache RAM
# TERM_ICON: 🧼
if sudo -n true 2>/dev/null; then
    sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1
else
    pkexec bash -c "sync && echo 3 > /proc/sys/vm/drop_caches" >/dev/null 2>&1
fi
echo -e "\n🌹 Tiffany : 🧼 Cache RAM purgé et mémoire libérée !\n"
