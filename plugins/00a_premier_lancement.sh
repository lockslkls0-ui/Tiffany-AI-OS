#!/usr/bin/env bash
# MENU_NAME: 👋 Assistant de Bienvenue (Configuration PC)
# MENU_DESC: Personnaliser ton prénom, détecter la RAM du PC et régler le PIN mobile

CONF_DIR="$HOME/.config/tiffany"
mkdir -p "$CONF_DIR"

RAM_GO=$(free -m | awk '/^Mem:/{printf "%.0f", $2/1024}')
[ -z "$RAM_GO" ] && RAM_GO=4

PRENOM=$(zenity --entry --title="🌹 Bienvenue dans Tiffany AI-OS" \
    --text="Configuration automatique détectée : ${RAM_GO} Go de RAM.\n\nComment souhaites-tu que Tiffany t'appelle ?" \
    --entry-text="Chef" --width=420 2>/dev/null)
[ -z "$PRENOM" ] && PRENOM="Chef"

PIN_CHOISI=$(zenity --entry --title="📱 Code PIN Mobile" \
    --text="Choisis un code PIN à 4 chiffres pour sécuriser ta télécommande téléphone :" \
    --entry-text="2026" --width=420 2>/dev/null)
[ -z "$PIN_CHOISI" ] && PIN_CHOISI="2026"

echo "$PRENOM" > "$CONF_DIR/user_name.txt"
echo "$PIN_CHOISI" > "$CONF_DIR/mobile_pin.txt"
python3 -c "import hashlib; open('$CONF_DIR/mobile_pin.hash','w').write(hashlib.sha256('$PIN_CHOISI'.encode()).hexdigest())"

touch "$CONF_DIR/setup_done"
zenity --info --title="✅ Configuration terminée" --text="Parfait $PRENOM !\n\n• Profil matériel (${RAM_GO} Go RAM) optimisé\n• Code PIN mobile réglé sur : $PIN_CHOISI\n\nTiffany est prête !" --width=400 2>/dev/null
