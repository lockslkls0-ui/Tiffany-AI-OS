#!/usr/bin/env bash
clear
echo -e "\033[1;35m🛠️  INVENTAIRE COMPLET DE L'ASSEMBLAGE DE TIFFANY\033[0m"
echo -e "-------------------------------------------------------------------"
echo -e "\033[1;33m🤖 MOTEURS D'IA LOCAUX (Ollama) :\033[0m"
if command -v ollama &>/dev/null; then
    ollama list 2>/dev/null || echo "  ❌ Impossible de joindre le serveur Ollama"
else
    echo "  ❌ Serveur Ollama introuvable"
fi
echo -e "\n\033[1;32m📦 MODULES PYTHON REQUIS ET RECONNAISSANCE :\033[0m"
python3 -c '
modules = ["requests", "spacy", "json", "shutil", "sys", "os"]
for m in modules:
    try:
        __import__(m)
        print(f"  ✅ {m} : Opérationnel")
    except ImportError:
        print(f"  ❌ {m} : Manquant")
'
echo -e "\n\033[1;36m⚙️  OUTILS ET ARCHITECTURE SYSTÈME LINUX REQUIS :\033[0m"
for cmd in espeak-ng zenity tesseract brightnessctl rfkill rhythmbox mpv cvlc; do
    if command -v "$cmd" &>/dev/null; then
        echo -e "  ✅ $cmd : Présent"
    else
        echo -e "  ❌ $cmd : Absent"
    fi
done
echo -e "\n\033[1;34m📊 ÉTAT DE LA MÉMOIRE ADMINISTRATIVE :\033[0m"
free -h
echo -e "-------------------------------------------------------------------"
echo -e "\n\033[1;35m🌹 Note du Créateur :\033[0m Tout est assemblé avec succès !"
echo -e "\n"
read -n 1 -s -r -p "👉 [Appuie sur n'importe quelle touche pour fermer]"
echo -e "\n"
