#!/bin/bash
# TERM_KEY: testia
# TERM_DESC: Stress Test complet de toute la matrice Tiffany
# TERM_ICON: 🧪
clear
echo -e "\033[1;35m🧪 [TIFFANY CORE] - GRAND AUDIT D'INTÉGRITÉ DE LA MATRICE INTERNE\033[0m"
echo -e "-------------------------------------------------------------------"
echo -n -e "🧠 1. MOTEUR COGNITIF (Ollama Qwen) : "
if command -v ollama >/dev/null; then
    TEST_LLM=$(ollama run qwen2.5:0.5b "Dis uniquement le mot OK" 2>/dev/null | head -n 1)
    if [ -n "$TEST_LLM" ]; then echo -e "\033[1;32m✅ En ligne ($TEST_LLM)\033[0m"; else echo -e "\033[1;31m❌ Modèle muet\033[0m"; fi
else echo -e "\033[1;31m❌ Serveur absent\033[0m"; fi

echo -n -e "🛡️  2. SENTINELLE THERMIQUE (Watchdog) : "
if pgrep -f thermal_watchdog.sh >/dev/null; then echo -e "\033[1;32m✅ Actif et en veille\033[0m"; else echo -e "\033[1;31m❌ Éteint\033[0m"; fi

echo -n -e "📡 3. RADAR SÉMANTIQUE (spaCy NLP) : "
if python3 -c "import spacy" >/dev/null 2>&1; then echo -e "\033[1;32m✅ Grammaire OK\033[0m"; else echo -e "\033[1;31m❌ Module manquant\033[0m"; fi
echo -n -e "🔎 4. CAPTEURS OPTIQUES (Tesseract OCR) : "
if command -v tesseract >/dev/null; then echo -e "\033[1;32m✅ Prêt pour les captures\033[0m"; else echo -e "\033[1;31m❌ Absent\033[0m"; fi

echo -n -e "📻 5. FLUX MULTIMÉDIA (Rhythmbox Client) : "
if command -v rhythmbox-client >/dev/null; then echo -e "\033[1;32m✅ Connecté au Hub\033[0m"; else echo -e "\033[1;31m❌ Absent\033[0m"; fi
echo -e "-------------------------------------------------------------------"
read -p "[Appuie sur Entrée pour fermer l'audit]"
