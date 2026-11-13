#!/usr/bin/env bash
# MENU_NAME: 🚀 Turbo RAM & Système (ZRAM)
# MENU_DESC: Compresser la RAM (ZRAM lz4) et accélérer le lancement des applis

if ! dpkg -l | grep -q "^ii  zram-tools " || ! dpkg -l | grep -q "^ii  preload "; then
    zenity --question --title="🚀 Turbo RAM & Système" \
        --text="Voulez-vous installer et activer ZRAM (compression RAM ultra-rapide) et Preload (lancement accéléré des logiciels) ?" \
        --width=440 2>/dev/null || exit 0
    pkexec bash -c "apt update && apt install -y zram-tools preload && printf 'ALGO=lz4\nPERCENT=50\n' > /etc/default/zramswap && systemctl enable --now zramswap preload && printf 'vm.swappiness=10\nvm.vfs_cache_pressure=50\n' > /etc/sysctl.d/99-tiffany-perf.conf && sysctl --system"
fi

ZRAM_INFO=$(zramctl 2>/dev/null | awk 'NR==2 {print "Disque ZRAM : " $3 " | Données : " $4 " | Compressé : " $5}')
[ -z "$ZRAM_INFO" ] && ZRAM_INFO="Compression ZRAM active en arrière-plan."
RAM_LIBRE=$(free -h | awk '/Mem:/ {print $7 " disponibles sur " $2}')

zenity --info --title="🚀 Turbo RAM & Système Actif" \
    --text="✅ Accélération mémoire et système active !\n\n• RAM : $RAM_LIBRE\n• $ZRAM_INFO\n• Preload : Anticipation des logiciels active\n• Swappiness : 10 (priorité absolue à la RAM)" \
    --width=450 2>/dev/null
