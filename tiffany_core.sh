#!/usr/bin/env bash
export PATH="$HOME/tiffany/bin:$PATH"
ROOT_DIR="$HOME/tiffany"
FIFO="/tmp/tiffany_chat.fifo"

trap '' SIGINT SIGQUIT
rm -f "$FIFO" && mkfifo "$FIFO"
trap "rm -f $FIFO" EXIT

clear
echo -e "\033[1;35m┌──────────────────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[1;35m│\033[1;36m   🌹 TIFFANY AI-OS  --  CONSOLE HYBRIDE & TERMINAL LINUX V48.5   \033[1;35m│\033[0m"
echo -e "\033[1;35m└──────────────────────────────────────────────────────────────────┘\033[0m"
BIENVENUE="Bonjour mon ange. Tu peux me parler, m'écrire ou taper n'importe quelle commande Linux (ls, htop, sudo...) ici."
echo -e "\033[1;34m 👉 Console verrouillée contre Ctrl+C (tape 'quitter' pour fermer). Écris 'aide' pour voir ta panoplie.\033[0m\n"
echo -e "\033[1;35m🌹 Tiffany :\033[0m $BIENVENUE\n"
(espeak-ng -v fr+f5 -s 145 -p 85 "Bonjour mon ange. Je suis prête." >/dev/null 2>&1) &
(curl -s http://localhost:11434/api/generate -d '{"model":"tiffany-flash","prompt":"","keep_alive":-1}' >/dev/null 2>&1) &

exec 3<> "$FIFO"

while true; do
    echo -n -e "\033[1;35m🌹 Tiffany\033[0m @ user-PORTEGE-R830:~$ "
    REQUETE=""
    while true; do
        # 1. Vérifie si un ordre vocal arrive via le tube FIFO (sans bloquer)
        if IFS= read -r -t 0.15 VOCAL_LINE <&3; then
            if [ -n "$VOCAL_LINE" ]; then
                REQUETE="$VOCAL_LINE"
                echo -e "\n\033[1;36m🎤 [Voix] :\033[0m $REQUETE"
                break
            fi
        fi
        # 2. Vérifie si tu tapes au clavier au premier plan (garde stdin intact pour htop, ls, sudo !)
        if IFS= read -r -t 0.15 KEY_LINE; then
            REQUETE="$KEY_LINE"
            break
        fi
    done

    [ -z "$REQUETE" ] && continue

    bash "$ROOT_DIR/tiffany_actions.sh" "$REQUETE"
    if [ $? -eq 99 ]; then
        (nice -n 19 python3 "$ROOT_DIR/diary_agent.py" >/dev/null 2>&1) &
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Session clôturée. À tout de suite mon amour."
        sleep 1
        break
    fi
done
