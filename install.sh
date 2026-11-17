#!/usr/bin/env bash
clear
echo -e "\033[1;35m🌹 Installation universelle clé en main de Tiffany AI-OS V48.6...\033[0m"
ROOT_DIR="$HOME/tiffany"
mkdir -p "$ROOT_DIR/memory" "$ROOT_DIR/logs" "$ROOT_DIR/diary" "$ROOT_DIR/agents" "$ROOT_DIR/dojo" "$ROOT_DIR/voice" "$HOME/.config/systemd/user" "$HOME/.local/share/icons/hicolor/256x256/apps"

# 1. Adapter tous les chemins et réinitialiser l'identité pour le nouvel utilisateur
find "$ROOT_DIR" -maxdepth 3 -type f \( -name "*.sh" -o -name "*.py" -o -name "*.json" -o -name "*.desktop" \) -exec sed -i "s|/home/user|$HOME|g" {} + 2>/dev/null
rm -f "$ROOT_DIR/memory/surnom_utilisateur.txt"
[ -f "$ROOT_DIR/tiffany_icon.png" ] && cp -f "$ROOT_DIR/tiffany_icon.png" "$HOME/.local/share/icons/hicolor/256x256/apps/tiffany-ai.png"

# 2. Paquets système et dépendances Python (Voix Siwis HD + Vosk + spaCy)
BUREAU_DIR=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Bureau")
mkdir -p "$BUREAU_DIR"
sudo apt update
sudo apt install -y espeak-ng zenity tesseract-ocr tesseract-ocr-fra brightnessctl rfkill rhythmbox mpv cvlc python3-pip cpulimit wmctrl xdotool smartmontools lm-sensors curl p7zip-full at
PIP_BREAK_SYSTEM_PACKAGES=1 pip3 install requests spacy vosk pyaudio yt-dlp ddgs piper-tts 2>/dev/null || pip3 install requests spacy vosk pyaudio yt-dlp ddgs piper-tts
PIP_BREAK_SYSTEM_PACKAGES=1 python3 -c "import spacy.cli; spacy.cli.download('fr_core_news_sm')" 2>/dev/null || true

# 3. Téléchargement automatique de la Voix Douce Siwis HD et de l'Oreille Vosk FR
if [ ! -f "$ROOT_DIR/voice/fr_FR-siwis-low.onnx" ]; then
    echo -e "\033[1;36m🎙️ Téléchargement de la voix neuronale Siwis HD...\033[0m"
    curl -sL "https://huggingface.co" -o "$ROOT_DIR/voice/fr_FR-siwis-low.onnx"
    curl -sL "https://huggingface.co.json" -o "$ROOT_DIR/voice/fr_FR-siwis-low.onnx.json"
fi
ln -sf "$ROOT_DIR/voice/fr_FR-siwis-low.onnx" "$ROOT_DIR/voice/voix_active.onnx"
ln -sf "$ROOT_DIR/voice/fr_FR-siwis-low.onnx.json" "$ROOT_DIR/voice/voix_active.onnx.json"
echo "piper" > "$ROOT_DIR/voice/mode_voix.txt"

python3 -c 'import vosk, os, shutil; vosk.Model(lang="fr"); dst=os.path.expanduser("~/tiffany/voice/vosk-fr/vosk-model-small-fr-0.22"); os.makedirs(os.path.dirname(dst), exist_ok=True); src=os.path.expanduser("~/.cache/vosk/vosk-model-small-fr-0.22"); os.path.exists(src) and not os.path.exists(dst) and shutil.copytree(src, dst)' 2>/dev/null || true

# 4. Moteurs IA locaux Ollama
if ! command -v ollama >/dev/null 2>&1; then curl -fsSL https://ollama.com | sh; fi
sudo systemctl enable --now ollama 2>/dev/null || sudo snap start ollama 2>/dev/null || true
sleep 3
ollama pull qwen2.5:1.5b
ollama pull qwen2.5:0.5b
ollama cp qwen2.5:0.5b tiffany-flash 2>/dev/null || true

# 5. Permissions, alias 'tiff' et raccourcis Bureau
chmod +x "$ROOT_DIR"/*.sh "$ROOT_DIR"/actions_terminal/*.sh "$ROOT_DIR"/plugins/*.sh "$ROOT_DIR"/bin/* 2>/dev/null
grep -q "alias tiff=" ~/.bashrc || echo "alias tiff='$ROOT_DIR/tiffany_core.sh'" >> ~/.bashrc

cat << EOD > "$BUREAU_DIR/Panneau Tiffany.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=🌹 Panneau Tiffany
Exec=$ROOT_DIR/tiffany_menu.sh
Icon=tiffany-ai
StartupWMClass=zenity
Categories=Utility;System;
Path=$ROOT_DIR
EOD
chmod +x "$BUREAU_DIR/Panneau Tiffany.desktop"
gio set "$BUREAU_DIR/Panneau Tiffany.desktop" metadata::trusted true 2>/dev/null || true

# 6. Activation automatique des 3 services permanents (Sentinelle Thermique + Oreille + Mémoire 30 min)
cat << EOW > "$HOME/.config/systemd/user/tiffany-watchdog.service"
[Unit]
Description=Sentinelle Thermique Auto-Regulee Tiffany AI-OS
After=graphical-session.target
[Service]
Type=simple
ExecStart=/bin/bash $ROOT_DIR/thermal_watchdog.sh
Restart=always
RestartSec=3
[Install]
WantedBy=default.target
EOW

cat << EOE > "$HOME/.config/systemd/user/tiffany-ear.service"
[Unit]
Description=Oreille Continue Vocale Tiffany AI-OS
After=graphical-session.target sound.target
[Service]
Type=simple
ExecStart=/bin/bash $ROOT_DIR/tiffany_ear_daemon.sh
Restart=always
RestartSec=3
[Install]
WantedBy=default.target
EOE

cat << EODP > "$HOME/.config/systemd/user/tiffany-diary.service"
[Unit]
Description=Archiviste Automatique Memoire Tiffany AI-OS
[Service]
Type=oneshot
ExecStart=/bin/bash -c "python3 $ROOT_DIR/memory_gardener.py && nice -n 19 python3 $ROOT_DIR/diary_agent.py"
EODP

cat << EODT > "$HOME/.config/systemd/user/tiffany-diary.timer"
[Unit]
Description=Execution toutes les 30 minutes de la Memoire Tiffany
[Timer]
OnBootSec=5min
OnUnitActiveSec=30min
Persistent=true
[Install]
WantedBy=timers.target
EODT

systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable --now tiffany-watchdog.service tiffany-ear.service tiffany-diary.timer 2>/dev/null || true

echo -e "\n\033[1;32m🏆 Installation terminée à 100 % ! Clique sur '🌹 Panneau Tiffany' ou tape 'tiff'.\033[0m\n"
