#!/usr/bin/env bash
set -e
ROOT="$HOME/tiffany"
VER="48.6"
BUREAU=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
DEB_DIR="/tmp/tiffany-ai-os_${VER}_all"
DEB_OUT="$BUREAU/tiffany-ai-os_${VER}_all.deb"

echo "=== 1/3 : RECONSTRUCTION DU PAQUET LOGITHÈQUE (.DEB V$VER) ==="
rm -rf "$DEB_DIR" && mkdir -p "$DEB_DIR/DEBIAN" "$DEB_DIR/opt/tiffany" "$DEB_DIR/usr/share/applications" "$DEB_DIR/usr/share/pixmaps"

# Copie propre sans données personnelles, journaux ni fichiers temporaires
rsync -a \
    --exclude='.git' \
    --exclude='backup/*' \
    --exclude='logs/*' \
    --exclude='memory/*' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='*.save' \
    --exclude='snapcraft-tiffany-ai-os-*.txt' \
    "$ROOT/" "$DEB_DIR/opt/tiffany/"

# Initialisation vierge pour le client (Mode Gratuit par défaut, activable par clé PRO)
mkdir -p "$DEB_DIR/opt/tiffany/logs" "$DEB_DIR/opt/tiffany/memory" "$DEB_DIR/opt/tiffany/backup" "$DEB_DIR/opt/tiffany/voice"
echo "espeak" > "$DEB_DIR/opt/tiffany/voice/mode_voix.txt"
[ -f "$ROOT/tiffany_icon.png" ] && cp "$ROOT/tiffany_icon.png" "$DEB_DIR/usr/share/pixmaps/tiffany-ai.png"

cat << 'EOA' > "$DEB_DIR/usr/share/applications/tiffany-ai-os.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=🌹 Tiffany AI-OS
Comment=Assistant Vocal Hybride & Gestionnaire Système Linux
Exec=bash -c "$HOME/tiffany/tiffany_menu.sh"
Icon=tiffany-ai
Terminal=false
Categories=Utility;System;
EOA

cat << EOD > "$DEB_DIR/DEBIAN/control"
Package: tiffany-ai-os
Version: $VER
Section: utils
Priority: optional
Architecture: all
Depends: bash, python3, python3-pip, zenity, espeak-ng, alsa-utils, ffmpeg, libnotify-bin, poppler-utils, tesseract-ocr, tesseract-ocr-fra, brightnessctl, rfkill, rhythmbox, mpv, cpulimit, wmctrl, xdotool, lm-sensors, curl, p7zip-full, at
Homepage: https://github.com/lockslkls0-ui/Tiffany-AI-OS/issues
Maintainer: LocksLks <lockslkls0-ui@users.noreply.github.com>
Description: Tiffany AI-OS - Assistant Vocal Hybride & Gestionnaire Systeme Linux
 Assistant intelligent 100% local propulse par Ollama, Vosk FR et Piper TTS.
 Pilote le refroidissement CPU, la RAM, le multimedia et les taches systeme.
EOD

cat << 'EOP' > "$DEB_DIR/DEBIAN/postinst"
#!/bin/bash
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
if [ -n "$REAL_HOME" ] && [ "$REAL_HOME" != "/root" ]; then
    cp -rn /opt/tiffany "$REAL_HOME/tiffany"
    chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/tiffany"
    su - "$REAL_USER" -c "bash '$REAL_HOME/tiffany/install.sh'" || true
fi
EOP
chmod 755 "$DEB_DIR/DEBIAN/postinst"
dpkg-deb --build "$DEB_DIR" "$DEB_OUT" >/dev/null
rm -rf "$DEB_DIR"
echo "✅ Paquet .deb commercial généré sur ton Bureau : $DEB_OUT"

echo -e "\n=== 2/3 : SYNCHRONISATION GITHUB (CODE PROPRE + TAG RELEASE V$VER) ==="
cd "$ROOT"
[ -f snap/snapcraft.yaml ] && sed -i "s/version:.*/version: \"$VER\"/" snap/snapcraft.yaml
git add -A
git commit -m "Release Commerciale PRO V$VER : Paquet .deb complet, isolation client et Freemium PRO" 2>/dev/null || true
git push -u origin main
git tag -f "v$VER" && git push -f origin "v$VER"
echo "✅ GitHub et Tag v$VER synchronisés !"

echo -e "\n=== 3/3 : RELEASE GITHUB (.deb) & SNAP STORE (SNAPCRAFT) ==="
if command -v gh >/dev/null 2>&1; then
    gh release delete "v$VER" -y 2>/dev/null || true
    gh release create "v$VER" "$HOME/Desktop"/*.deb --title "Tiffany AI-OS v$VER" --notes "Release officielle Linux (.deb) - 100% locale" && echo "✅ Fichier .deb publié dans les Releases GitHub !"
fi
if command -v snapcraft >/dev/null 2>&1; then
    nohup snapcraft remote-build --launchpad-accept-public-upload > /tmp/snapcraft_build.log 2>&1 &
    echo "🚀 Vrai build Launchpad lancé en arrière-plan (suivi dans /tmp/snapcraft_build.log) !"
fi
echo -e "\n🏆 PUBLICATION MULTI-PLATEFORMES PROFESSIONNELLE TERMINÉE !"
