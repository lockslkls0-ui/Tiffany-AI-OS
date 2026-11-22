#!/usr/bin/env bash
set -e
ROOT="$HOME/tiffany"
VER="48.6"
DEB_DIR="/tmp/tiffany-ai-os_${VER}_all"
DEB_OUT="$HOME/Bureau/tiffany-ai-os_${VER}_all.deb"

echo "=== 1/3 : RECONSTRUCTION DU PAQUET LOGITHÈQUE (.DEB V$VER) ==="
rm -rf "$DEB_DIR" && mkdir -p "$DEB_DIR/DEBIAN" "$DEB_DIR/opt/tiffany" "$DEB_DIR/usr/share/applications" "$DEB_DIR/usr/share/pixmaps"

# Copie propre sans les données personnelles ni les fichiers temporaires
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

mkdir -p "$DEB_DIR/opt/tiffany/logs" "$DEB_DIR/opt/tiffany/memory" "$DEB_DIR/opt/tiffany/backup"
[ -f "$ROOT/tiffany_icon.png" ] && cp "$ROOT/tiffany_icon.png" "$DEB_DIR/usr/share/pixmaps/tiffany-ai.png"

cat << EOD > "$DEB_DIR/DEBIAN/control"
Package: tiffany-ai-os
Version: $VER
Section: utils
Priority: optional
Architecture: all
Depends: bash, python3, python3-pip, zenity, espeak-ng, tesseract-ocr, tesseract-ocr-fra, brightnessctl, rfkill, rhythmbox, mpv, cpulimit, wmctrl, xdotool, lm-sensors, curl, p7zip-full, at
Homepage: https://github.com
Maintainer: LocksLks <lockslkls0-ui@://github.com>
Description: Tiffany AI-OS - Assistant Vocal Hybride & Gestionnaire Systeme Linux
 Assistant intelligent local propulse par Ollama, Vosk FR et Piper TTS.
 Pilote le refroidissement CPU, la RAM, le multimedia et les taches systeme.
EOD

cat << EOP > "$DEB_DIR/DEBIAN/postinst"
#!/bin/bash
REAL_HOME=\$(getent passwd "\${SUDO_USER:-\$USER}" | cut -d: -f6)
if [ -n "\$REAL_HOME" ] && [ "\$REAL_HOME" != "/root" ]; then
    cp -rn /opt/tiffany "\$REAL_HOME/tiffany"
    chown -R "\${SUDO_USER:-\$USER}:" "\$REAL_HOME/tiffany"
    su - "\${SUDO_USER:-\$USER}" -c "bash '\$REAL_HOME/tiffany/install.sh'" || true
fi
EOP
chmod 755 "$DEB_DIR/DEBIAN/postinst"
dpkg-deb --build "$DEB_DIR" "$DEB_OUT" >/dev/null
rm -rf "$DEB_DIR"
echo "✅ Paquet .deb professionnel généré : $DEB_OUT"

echo -e "\n=== 2/3 : SYNCHRONISATION GITHUB (CODE PROPRE + TAG RELEASE V$VER) ==="
cd "$ROOT"
[ -f snap/snapcraft.yaml ] && sed -i "s/version:.*/version: \"$VER\"/" snap/snapcraft.yaml
git add -A
git commit -m "Release Pro V$VER : Nettoyage depot, dependances .deb et isolation donnees" 2>/dev/null || true
git push -u origin main
git tag -f "v$VER" && git push -f origin "v$VER"
echo "✅ GitHub et Tag v$VER synchronisés !"

echo -e "\n=== 3/3 : DÉCLENCHEMENT SNAP STORE (SNAPCRAFT) ==="
if command -v snapcraft >/dev/null 2>&1; then
    nohup snapcraft remote-build --launchpad-accept-public-upload >/tmp/snapcraft_build.log 2>&1 &
    echo "🚀 Build Snap lancé en arrière-plan sur Launchpad !"
else
    echo "ℹ️ Snapcraft CLI non installé localement."
fi
echo -e "\n🏆 PUBLICATION MULTI-PLATEFORMES PROFESSIONNELLE TERMINÉE !"
