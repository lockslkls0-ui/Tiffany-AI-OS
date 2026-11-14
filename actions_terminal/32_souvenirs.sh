#!/usr/bin/env bash
# TERM_KEY: souvenirs
# TERM_DESC: Afficher en clair tout ce dont Tiffany se souvient en direct
# TERM_ICON: 🧠

echo -e "\n\033[1;35m🧠 [PREUVE DE MÉMOIRE ACTIVE & RAPPORTS LUS EN DIRECT] :\033[0m"
echo -e "-------------------------------------------------------------------"
python3 "$HOME/tiffany/lire_memoire_totale.py" | sed 's/ | /\n  📌 /g; s/^/  📌 /'
echo -e "-------------------------------------------------------------------\n"
