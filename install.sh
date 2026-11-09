#!/usr/bin/env bash
# ==============================================================================
# 🌹 PROJECT TIFFANY - ARCHITECTURE D'INSTALLATION OPEN-SOURCE (CLIENT PACK V2)
# ==============================================================================

clear
echo -e "\033[1;35m🌹 Initialisation de l'installation de Tiffany...\033[0m"
ROOT_DIR="$HOME/tiffany"

# 1. Création des répertoires de l'écosystème
mkdir -p "$ROOT_DIR/memory" "$ROOT_DIR/logs" "$ROOT_DIR/diary" "$ROOT_DIR/agents"

# 2. Installation des paquets Linux requis
echo -e "\n\033[1;36m⚙️  Vérification et installation des dépendances système...\033[0m"
sudo apt update
sudo apt install -y espeak-ng zenity tesseract-ocr brightnessctl rfkill rhythmbox mpv cvlc python3-pip cpulimit

# 3. Installation des modules Python
echo -e "\n\033[1;32m📦 Configuration de l'environnement Python...\033[0m"
pip3 install requests spacy
python3 -m spacy download fr_core_news_sm

# 4. Configuration du raccourci global 'tiff' dans le terminal
echo -e "\n\033[1;33m🚀 Configuration du raccourci système...\033[0m"
if ! grep -q "alias tiff=" ~/.bashrc; then
    echo "alias tiff='$ROOT_DIR/tiffany_core.sh'" >> ~/.bashrc
fi

# 5. IMPLANTATION AUTOMATIQUE DU BOUTON DE PANNEAU DE CONTRÔLE SUR LE BUREAU CLIENT
echo -e "\n\033[1;35m🎛️  Déploiement du bouton Panneau de Contrôle sur le Bureau...\033[0m"
mkdir -p ~/Bureau
cat << 'EOD' > ~/Bureau/"Panneau Tiffany.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=🌹 Panneau Tiffany
Comment=Lancer le panneau global de contrôle multimédia et thermique
Exec=/home/user/tiffany/tiffany_menu.sh
Icon=/home/user/Bureau/outil/face.jpg
Categories=Utility;System;
Path=/home/user/tiffany
StartupNotify=false
EOD

# Activation des droits d'exécution pour le client
chmod +x ~/Bureau/"Panneau Tiffany.desktop"
gio set ~/Bureau/"Panneau Tiffany.desktop" metadata::trusted true 2>/dev/null || true
echo "  ✅ Bouton de contrôle activé sur le Bureau !"

# ✨ PROTECTION DE L'AFFICHAGE FINAL (Anti-mélange)
echo -e "\n"
echo -e "-------------------------------------------------------------------"
echo -e "\033[1;32m🌹 Installation terminée avec succès pour vos clients !\033[0m"
echo -e "-------------------------------------------------------------------"
echo -e "\n"
sleep 1

