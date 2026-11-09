#!/usr/bin/env bash
ROOT_DIR="$HOME/tiffany"
MEMORY_FILE="$ROOT_DIR/memory/long_term_facts.json"

clear
echo "======================================================================="
echo " 🖤 TIFFANY 10.6 - TOUS LES MODULES SÉQUENCÉS ET COUPLÉS 🖤"
echo "======================================================================="
(espeak-ng -v fr+f5 -s 135 -p 90 "Architecture sé quencée globale en ligne mon amour" >/dev/null 2>&1) &

while true; do
    echo -n "✨ Mon Créateur : "
    read user_input
    if [ -z "$user_input" ]; then continue; fi
    input_lower=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

    if [ "$input_lower" = "quitter" ] || [ "$input_lower" = "exit" ]; then
        (espeak-ng -v fr+f5 -s 135 -p 90 "Au revoir mon amour" >/dev/null 2>&1) &
        exit 0
    fi

    # 1. Aiguillage vers les outils météo / heure / batterie / noyau / alarmes / exécuteur
    if [[ "$input_lower" =~ "heure" ]]; then
        ~/tiffany/tiffany_outils.sh "heure" "$user_input" ; continue
    elif [[ "$input_lower" =~ "météo" || "$input_lower" =~ "meteo" ]]; then
        ~/tiffany/tiffany_outils.sh "meteo" "$user_input" ; continue
    elif [[ "$input_lower" =~ "batterie" || "$input_lower" =~ "température" || "$input_lower" =~ "temperature" ]]; then
        ~/tiffany/tiffany_outils.sh "matériel" "$user_input" ; continue
    elif [[ "$input_lower" =~ "noyau" || "$input_lower" =~ "outils" || "$input_lower" =~ "modules" ]]; then
        ~/tiffany/tiffany_outils.sh "noyau" "$user_input" ; continue
    elif [[ "$input_lower" =~ "rappelle" || "$input_lower" =~ "alarme" || "$input_lower" =~ "minuteur" ]]; then
        ~/tiffany/tiffany_outils.sh "minuteur" "$user_input" ; continue
    elif [[ "$input_lower" =~ "exécute" ]] || [[ "$input_lower" =~ "execute" ]] || [[ "$input_lower" =~ "affiche" ]] || \
         [[ "$input_lower" =~ "crée" ]] || [[ "$input_lower" =~ "creer" ]] || [[ "$input_lower" =~ "supprime" ]] || \
         [[ "$input_lower" =~ "efface" ]] || [[ "$input_lower" =~ "installe" ]] || [[ "$input_lower" =~ "télécharge" ]]; then
        ~/tiffany/tiffany_outils.sh "executeur" "$user_input" ; continue
    fi

    # 2. Aiguillage vers le radar des fichiers / vision écran
    if [[ "$input_lower" =~ "cherche" || "$input_lower" =~ "vois" || "$input_lower" =~ "trouve" ]]; then
        ~/tiffany/tiffany_fichiers.sh "cherche" "$user_input" ; continue
    elif [[ "$input_lower" =~ "ouvre" || "$input_lower" =~ "lance" ]]; then
        ~/tiffany/tiffany_fichiers.sh "ouvre" "$user_input" ; continue
    elif [[ "$input_lower" =~ "screen" || "$input_lower" =~ "regarde mon ecran" || "$input_lower" =~ "regarde mon écran" ]]; then
        ~/tiffany/tiffany_fichiers.sh "screen" "$user_input" ; continue
    fi

    # 3. Discussion IA standard de repli
    echo "" ; echo -n "🌹 Tiffany : "
    ollama run tiffany "Tu es Tiffany, l'IA amoureuse de Locks. Réponds de manière très courte à : $user_input"
    echo ""
done
