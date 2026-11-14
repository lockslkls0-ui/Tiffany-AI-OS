#!/usr/bin/env bash
ROOT_DIR="$HOME/tiffany"
FIFO="/tmp/tiffany_chat.fifo"

# Bouclier anti-fermeture : ignore Ctrl+C lors de la copie à la souris !
trap '' SIGINT SIGQUIT

rm -f "$FIFO" && mkfifo "$FIFO"
clear
echo -e "\033[1;35m┌──────────────────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[1;35m│\033[1;36m   🌹 TIFFANY AI-OS  --  CONSOLE PERSISTANTE SÉCURISÉE V48.4       \033[1;35m│\033[0m"
echo -e "\033[1;35m└──────────────────────────────────────────────────────────────────┘\033[0m"
BIENVENUE="Bonjour mon ange. Cette fenêtre est verrouillée contre les fermetures accidentelles (tape 'quitter' pour fermer)."
echo -e "\033[1;34m 👉 Astuce copie : sélectionne à la souris ou utilise Ctrl+Maj+C. Écris 'aide' pour voir ta panoplie.\033[0m\n"
echo -e "\033[1;35m🌹 Tiffany :\033[0m $BIENVENUE\n"
(espeak-ng -v fr+f5 -s 145 -p 85 "Bonjour mon ange. Je suis prête." >/dev/null 2>&1) &
(curl -s http://localhost:11434/api/generate -d '{"model":"tiffany-flash","prompt":"","keep_alive":"15m"}' >/dev/null 2>&1) &

while IFS= read -r LINE; do
    [ -n "$LINE" ] && echo "$LINE" > "$FIFO"
done &
KEY_PID=$!

trap "kill $KEY_PID 2>/dev/null; rm -f $FIFO" EXIT

exec 3<> "$FIFO"
while IFS= read -r REQUETE <&3; do
    [ -z "$REQUETE" ] && continue
    echo -e "\033[1;36m💬 Reçu :\033[0m $REQUETE"
    bash "$ROOT_DIR/tiffany_actions.sh" "$REQUETE"
    if [ $? -eq 99 ]; then
        (nice -n 19 python3 "$ROOT_DIR/diary_agent.py" >/dev/null 2>&1) &
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Session clôturée. À tout de suite mon amour."
        sleep 1
        break
    fi
    echo -n -e "\033[1;35m🌹 Tiffany\033[0m @ user-PORTEGE-R830:~$ "
done
