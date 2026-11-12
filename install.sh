#!/usr/bin/env bash
clear
echo -e "\033[1;35m🌹 Installation universelle de Tiffany AI-OS...\033[0m"
ROOT_DIR="$HOME/tiffany"
mkdir -p "$ROOT_DIR/memory" "$ROOT_DIR/logs" "$ROOT_DIR/diary" "$ROOT_DIR/agents" "$ROOT_DIR/dojo"

find "$ROOT_DIR" -maxdepth 3 -type f \( -name "*.sh" -o -name "*.py" -o -name "*.json" -o -name "*.desktop" \) -exec sed -i "s|/home/user|$HOME|g" {} + 2>/dev/null
BUREAU_DIR=$(xdg-user-dir DESKTOP 2>/dev/null)
[ -z "$BUREAU_DIR" ] && BUREAU_DIR="$HOME/Bureau"
mkdir -p "$BUREAU_DIR"
sudo apt update
sudo apt install -y espeak-ng zenity tesseract-ocr tesseract-ocr-fra brightnessctl rfkill rhythmbox mpv cvlc python3-pip cpulimit wmctrl xdotool smartmontools lm-sensors curl
pip3 install --break-system-packages requests spacy yt-dlp ddgs 2>/dev/null || pip3 install requests spacy yt-dlp ddgs
python3 -m spacy download fr_core_news_sm

if ! command -v ollama >/dev/null 2>&1; then curl -fsSL https://ollama.com | sh; fi
sudo systemctl enable --now ollama 2>/dev/null
sleep 3
ollama pull qwen2.5:1.5b
ollama pull qwen2.5:0.5b
ollama cp qwen2.5:0.5b tiffany-flash 2>/dev/null
chmod +x "$ROOT_DIR"/*.sh "$ROOT_DIR"/actions_terminal/*.sh "$ROOT_DIR"/plugins/*.sh 2>/dev/null
grep -q "alias tiff=" ~/.bashrc || echo "alias tiff='$ROOT_DIR/tiffany_core.sh'" >> ~/.bashrc

cat << EOD > "$BUREAU_DIR/Panneau Tiffany.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=🌹 Panneau Tiffany
Exec=$ROOT_DIR/tiffany_menu.sh
Icon=$ROOT_DIR/face.jpg
Categories=Utility;System;
Path=$ROOT_DIR
EOD

chmod +x "$BUREAU_DIR/Panneau Tiffany.desktop"
gio set "$BUREAU_DIR/Panneau Tiffany.desktop" metadata::trusted true 2>/dev/null || true
echo -e "\n\033[1;32m🌹 Installation terminée ! Double-clique sur 'Panneau Tiffany'.\033[0m\n"
