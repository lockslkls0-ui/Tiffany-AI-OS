#!/usr/bin/env bash
# TERM_KEY: noyau
# TERM_DESC: Moteurs IA, nouveaux sens et paquets système requis
# TERM_ICON: 🧠

ROOT_DIR="$HOME/tiffany"

echo -e "\n\033[1;35m🧠 [MOTEURS IA, SENS & DÉPENDANCES SYSTÈME V47.6] :\033[0m"
echo -e "-------------------------------------------------------------------"

echo -e "\033[1;36m  [ MOTEURS NEURONAUX OLLAMA ]\033[0m"
if command -v ollama >/dev/null 2>&1; then
    ollama list 2>/dev/null | sed 's/^/   🧠 /'
else
    echo -e "   ❌ [ALERTE] Moteur Ollama introuvable"
fi

echo -e "\n\033[1;36m  [ CONFIGURATION PACK LINUX & PERFORMANCE ]\033[0m"
for pkg in espeak-ng zenity tesseract-ocr brightnessctl rfkill rhythmbox mpv python3-pip cpulimit xdotool zram-tools preload usbutils bluez; do
    if dpkg -l | grep -q "^ii  $pkg " 2>/dev/null; then
        echo -e "   [\033[1;32m  OK  \033[0m] Paquet système : $pkg"
    else
        echo -e "   [\033[1;31mMANQUE\033[0m] Paquet système : $pkg"
    fi
done

echo -e "\n\033[1;36m  [ MODULES PYTHON3 & OUÏE VOCALE ]\033[0m"
for mod in requests spacy vosk pyaudio; do
    if python3 -c "import $mod" >/dev/null 2>&1; then
        echo -e "   [\033[1;32m  OK  \033[0m] Module Python : $mod"
    else
        echo -e "   [\033[1;31mMANQUE\033[0m] Module Python : $mod"
    fi
done

if python3 -m spacy info fr_core_news_sm >/dev/null 2>&1; then
    echo -e "   [\033[1;32m  OK  \033[0m] Modèle linguistique : fr_core_news_sm"
else
    echo -e "   [\033[1;31mMANQUE\033[0m] Modèle linguistique : fr_core_news_sm"
fi

if [ -d "$ROOT_DIR/voice/vosk-fr/vosk-model-small-fr-0.22" ]; then
    echo -e "   [\033[1;32m  OK  \033[0m] Modèle vocal Ouïe : vosk-model-small-fr-0.22"
else
    echo -e "   [\033[1;31mMANQUE\033[0m] Modèle vocal Ouïe : vosk-model-small-fr-0.22"
fi

echo -e "-------------------------------------------------------------------"
echo -e "\033[1;36m  [ SÉCURITÉ MATÉRIELLE & SENTINELLE PERMANENTE ]\033[0m"
systemctl --user is-active tiffany-watchdog.service 2>/dev/null | grep -q "^active$" && echo -e "   [\033[1;32m  OK  \033[0m] Sentinelle Thermique Permanente (76°C / 63°C)" || echo -e "   [\033[1;31mMANQUE\033[0m] Sentinelle Thermique Permanente"
[ -f "/etc/systemd/system/ollama.service.d/limit.conf" ] && echo -e "   [\033[1;32m  OK  \033[0m] Bouclier CPU Systemd (80% max)" || echo -e "   [\033[1;31mMANQUE\033[0m] Bouclier CPU Systemd"
[ -d "$ROOT_DIR/dojo" ] && echo -e "   [\033[1;32m  OK  \033[0m] Espace clos Dojo : ~/tiffany/dojo" || echo -e "   [\033[1;31mMANQUE\033[0m] Espace clos Dojo"
echo ""
