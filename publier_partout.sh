#!/usr/bin/env bash
set -e
ROOT="$HOME/tiffany"
VER="48.6"
DEB_DIR="/tmp/tiffany-ai-os_${VER}_all"
DEB_OUT="$HOME/Bureau/tiffany-ai-os_${VER}_all.deb"

echo "=== 1/3 : RECONSTRUCTION DU PAQUET LOGITHÈQUE (.DEB V$VER) ==="
rm -rf "$DEB_DIR" && mkdir -p "$DEB_DIR/DEBIAN" "$DEB_DIR/opt/tiffany" "$DEB_DIR/usr/share/applications" "$DEB_DIR/usr/share/pixmaps"
rsync -a --exclude='.git' --exclude='backup' --exclude='logs/*' "$ROOT/" "$DEB_DIR/opt/tiffany/"
[ -f "$ROOT/tiffany_icon.png" ] && cp "$ROOT/tiffany_icon.png" "$DEB_DIR/usr/share/pixmaps/tiffany-ai.png"

cat << EOD > "$DEB_DIR/DEBIAN/control"
Package: tiffany-ai-os
Version: $VER
Section: utils
Priority: optional
Architecture: all
Maintainer: LocksLks <lockslkls0-ui@://github.com>
Description: Tiffany AI-OS V$VER - Assistant Vocal & Systeme Linux Mint
EOD

cat << EOP > "$DEB_DIR/DEBIAN/postinst"
#!/bin/bash
REAL_HOME=\$(getent passwd "\${SUDO_USER:-\$USER}" | cut -d: -f6)
[ -n "\$REAL_HOME" ] && cp -rn /opt/tiffany "\$REAL_HOME/tiffany" && chown -R "\${SUDO_USER:-\$USER}:" "\$REAL_HOME/tiffany" && bash "\$REAL_HOME/tiffany/install.sh"
EOP
chmod 755 "$DEB_DIR/DEBIAN/postinst"
dpkg-deb --build "$DEB_DIR" "$DEB_OUT" >/dev/null
rm -rf "$DEB_DIR"
echo "✅ Paquet .deb généré sur le Bureau : $DEB_OUT"

echo -e "\n=== 2/3 : SYNCHRONISATION GITHUB (CODE + TAG RELEASE V$VER) ==="
cd "$ROOT"
[ -f snap/snapcraft.yaml ] && sed -i "s/version:.*/version: \"$VER\"/" snap/snapcraft.yaml
git add -A
git commit -m "Publication officielle Multi-Plateformes V$VER" 2>/dev/null || true
git push -u origin main
git tag -f "v$VER" && git push -f origin "v$VER"
echo "✅ GitHub et Tag v$VER synchronisés !"

echo -e "\n=== 3/3 : DÉCLENCHEMENT SNAP STORE (SNAPCRAFT) ==="
if command -v snapcraft >/dev/null 2>&1; then
    snapcraft remote-build --launchpad-accept-public-upload 2>/dev/null || echo "ℹ️ Snapcraft : vérifie ta connexion 'snapcraft login' si besoin."
else
    echo "ℹ️ Snapcraft CLI non installé localement (GitHub déclenche automatiquement le build Snap Store s'il est lié)."
fi
echo -e "\n🏆 PUBLICATION MULTI-PLATEFORMES TERMINÉE !"
