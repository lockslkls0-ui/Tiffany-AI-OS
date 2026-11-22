#!/usr/bin/env bash
export DISPLAY="${DISPLAY:-:0}"
BUREAU=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
VAULT_ROOT="$HOME/.local/share/tiffany_coffres"
mkdir -p "$VAULT_ROOT"
ACTION="${1:-creer}"
NOM="$2"

creer_icone_bureau() {
    local N="$1"
    local DESK="$BUREAU/${N}.desktop"
    cat << EOD > "$DESK"
[Desktop Entry]
Version=1.0
Type=Application
Name=🔐 $N
Comment=Dossier sécurisé par code secret
Exec=bash "$HOME/tiffany/coffre_fort.sh" ouvrir "$N"
Icon=dialog-password
Terminal=false
Actions=Supprimer;

[Desktop Action Supprimer]
Name=🗑️ Supprimer ce dossier (Code requis)
Exec=bash "$HOME/tiffany/coffre_fort.sh" supprimer "$N"
EOD
    chmod 755 "$DESK"
    gio set "$DESK" metadata::trusted true 2>/dev/null || true
    pkexec chattr +i "$DESK" 2>/dev/null || true
}
