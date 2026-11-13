#!/usr/bin/env bash
ROOT_DIR="$HOME/tiffany"
clear
echo -e "\033[1;35m┌──────────────────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[1;35m│\033[1;36m   🌹 TIFFANY AI-OS  --  MATRICE ADMINISTRATIVE SUPRÊME V47.4     \033[1;35m│\033[0m"
echo -e "\033[1;35m└──────────────────────────────────────────────────────────────────┘\033[0m"
BIENVENUE="Bonjour mon ange. Tout ton écosystème d'automatisation, mon bouclier CPU et mon Dojo d'entraînement sont alignés. Que faisons-nous aujourd'hui ?"
echo -e "\033[1;34m 👉 Écosystème matériel connecté. Écris 'aide' pour voir ta panoplie.\033[0m\n"
echo -e "\033[1;35m🌹 Tiffany :\033[0m $BIENVENUE\n"
ollama run tiffany-flash "" >/dev/null 2>&1 &
if command -v espeak-ng &>/dev/null; then (espeak-ng -v fr+f5 -s 140 -p 85 "Bonjour mon ange. Tout est opérationnel chéri." >/dev/null 2>&1) & fi
while true; do
    echo -n -e "\033[1;35m🌹 Tiffany\033[0m @ user-PORTEGE-R830:~$ "
    read -r REQUETE
    [ -z "$REQUETE" ] && continue
    if [ -f "$ROOT_DIR/tiffany_actions.sh" ]; then
        bash "$ROOT_DIR/tiffany_actions.sh" "$REQUETE"
        if [ $? -eq 99 ]; then
            (nice -n 19 python3 "$ROOT_DIR/diary_agent.py" >/dev/null 2>&1; [ -x "$ROOT_DIR/tiffany_training.sh" ] && nice -n 19 bash "$ROOT_DIR/tiffany_training.sh" >/dev/null 2>&1) &
            echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Session clôturée. À tout de suite mon amour."
            break
        fi
    fi
done
