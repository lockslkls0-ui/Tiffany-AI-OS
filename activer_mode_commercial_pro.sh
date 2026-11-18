#!/usr/bin/env bash
zenity --question --title="💎 Activation Commerciale Tiffany AI-OS PRO" \
    --text="Es-tu prêt à basculer la version publique (GitHub / Snap / .deb) en modèle Freemium (Gratuit + Option PRO) ?\n\n• Chez toi : ta licence Créateur reste active à 100 %.\n• En ligne : la Voix Douce Siwis HD, PDF et Web-IA demanderont une clé TIFFANY-PRO-XXXX." \
    --width=460 2>/dev/null || exit 0

mkdir -p ~/.config/tiffany
echo "TIFFANY-PRO-CREATOR-LOCKSLKLS-2026" > ~/.config/tiffany/pro_license.key

# Activer le plugin dans le Panneau (en retirant le .off s'il était désactivé)
[ -f ~/tiffany/plugins/00c_activer_pro.sh.off ] && mv ~/tiffany/plugins/00c_activer_pro.sh.off ~/tiffany/plugins/00c_activer_pro.sh
chmod +x ~/tiffany/plugins/00c_activer_pro.sh

# Lancer la publication globale (GitHub + .deb + Snap)
bash ~/tiffany/publier_partout.sh
zenity --info --title="🚀 Mode Commercial PRO en Ligne !" --text="✅ Tiffany AI-OS est maintenant publié avec l'Édition PRO activable par clé !" --width=400 2>/dev/null
