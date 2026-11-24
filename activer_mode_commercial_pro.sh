#!/usr/bin/env bash
zenity --question --title="💎 Bascule Commerciale Tiffany AI-OS PRO" \
    --text="Es-tu prêt à basculer la version publique (GitHub / Snap / .deb) en mode Freemium PRO ?\n\n• Chez toi : ta licence Créateur reste active à 100 %.\n• En ligne : les utilisateurs devront acheter une clé à 16 € sur Gumroad pour débloquer la Voix Siwis HD, PDF, Web-IA et le Mobile." \
    --width=480 2>/dev/null || exit 0

mkdir -p ~/.config/tiffany
echo "TIFFANY-PRO-CREATOR-LOCKSLKLS-2026" > ~/.config/tiffany/pro_license.key

# Réactiver le verrou PRO sur les modules avancés
for f in ~/tiffany/actions_terminal/25_webia.sh ~/tiffany/actions_terminal/35_lire_pdf.sh ~/tiffany/plugins/35_bascule_voix.sh ~/tiffany/plugins/90_parametres_mobile.sh; do
    sed -i 's/pro_license_disabled_launch/pro_license.key/g' "$f" 2>/dev/null || true
done

[ -f ~/tiffany/plugins/00c_activer_pro.sh.off ] && mv ~/tiffany/plugins/00c_activer_pro.sh.off ~/tiffany/plugins/00c_activer_pro.sh
chmod +x ~/tiffany/plugins/00c_activer_pro.sh

bash ~/tiffany/publier_partout.sh
zenity --info --title="🚀 Mode Commercial PRO en Ligne !" --text="✅ Tiffany AI-OS est maintenant publié avec l'Édition PRO payante (16 €) !" --width=420 2>/dev/null
