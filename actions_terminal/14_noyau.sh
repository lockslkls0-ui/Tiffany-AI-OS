#!/usr/bin/env bash
# TERM_KEY: noyau
# TERM_DESC: Moteurs IA et paquets système requis
# TERM_ICON: 🧠

ROOT_DIR="$HOME/tiffany"

echo -e "\n\033[1;35m🧠 [MOTEURS IA & DEPENDANCES SYSTEME] :\033[0m"
echo -e "-------------------------------------------------------------------"

# 1. Modèles Ollama
echo -e "\033[1;36m  [ MOTEURS NEURONAUX OLLAMA ]\033[0m"
if command -v ollama >/dev/null 2>&1; then
    ollama list 2>/dev/null | sed 's/^/   🧠 /'
else
    echo -e "   ❌ [ALERTE] Moteur Ollama introuvable"
fi

# 2. Dépendances Linux requises (install.sh)
echo -e "\n\033[1;36m  [ CONFIGURATION PACK LINUX REQUIS ]\033[0m"
for pkg in espeak-ng zenity tesseract-ocr brightnessctl rfkill rhythmbox mpv cvlc python3-pip cpulimit; do
    if dpkg -l | grep -q "^ii  $pkg " 2>/dev/null; then
        echo -e "   [\033[1;32m  OK  \033[0m] Paquet système : $pkg"
    else
        echo -e "   [\033[1;31mMANQUE\033[0m] Paquet système : $pkg"
    fi
done

# 3. Dépendances Python (requests, spacy)
echo -e "\n\033[1;36m  [ LOGICIELS & MODULES PYTHON3 ]\033[0m"
for mod in requests spacy; do
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
echo -e "-------------------------------------------------------------------"
echo -e "\033[1;36m  [ SÉCURITÉ MATÉRIELLE & SANDBOX V47 ]\033[0m"
[ -f "/etc/systemd/system/ollama.service.d/limit.conf" ] && echo -e "   [\033[1;32m  OK  \033[0m] Bouclier CPU Systemd (80% max)" || echo -e "   [\033[1;31mMANQUE\033[0m] Bouclier CPU Systemd"
[ -d "$ROOT_DIR/dojo" ] && echo -e "   [\033[1;32m  OK  \033[0m] Espace clos Dojo : ~/tiffany/dojo" || echo -e "   [\033[1;31mMANQUE\033[0m] Espace clos Dojo"
echo ""

