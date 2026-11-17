#!/usr/bin/env bash
export PATH="$HOME/tiffany/bin:$PATH"
ROOT_DIR="$HOME/tiffany"
FIFO="/tmp/tiffany_chat.fifo"

# Verrou instance unique : ferme automatiquement toute ancienne instance en double
exec 9>/tmp/tiffany_core.lock
if ! flock -n 9; then
    pkill -9 -f "tiffany_core.sh" 2>/dev/null || true
    sleep 0.3
fi

trap '' SIGINT SIGQUIT
rm -f "$FIFO" && mkfifo "$FIFO"
trap "python3 $ROOT_DIR/memory_gardener.py >/dev/null 2>&1; nice -n 19 python3 $ROOT_DIR/diary_agent.py >/dev/null 2>&1 & rm -f $FIFO /tmp/tiffany_core_ready /tmp/tiffany_core.lock" EXIT

clear
echo -e "\033[1;35m┌──────────────────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[1;35m│\033[1;36m   🌹 TIFFANY AI-OS  --  CONSOLE HYBRIDE & TERMINAL LINUX V48.6   \033[1;35m│\033[0m"
echo -e "\033[1;35m└──────────────────────────────────────────────────────────────────┘\033[0m"
BIENVENUE="Bonjour mon ange. Tu peux me parler, m'écrire ou taper n'importe quelle commande Linux (ls, htop, sudo...) ici."
echo -e "\033[1;34m 👉 Console verrouillée contre Ctrl+C (tape 'quitter' pour fermer). Écris 'aide' pour voir ta panoplie.\033[0m\n"
echo -e "\033[1;35m🌹 Tiffany :\033[0m $BIENVENUE\n"
("$HOME/tiffany/bin/espeak-ng" "Bonjour mon ange. Je suis prête." >/dev/null 2>&1) &
(curl -s http://localhost:11434/api/generate -d '{"model":"tiffany-flash","prompt":"","keep_alive":-1}' >/dev/null 2>&1) &

exec 3<> "$FIFO"
touch /tmp/tiffany_core_ready

while true; do
    echo -n -e "\033[1;35m🌹 Tiffany\033[0m @ user-PORTEGE-R830:~$ "
    REQUETE=""
    while true; do
        if IFS= read -r -t 0.15 VOCAL_LINE <&3; then
            if [ -n "$VOCAL_LINE" ]; then
                REQUETE="$VOCAL_LINE"
                echo -e "\n\033[1;36m🎤 [Voix] :\033[0m $REQUETE"
                break
            fi
        fi
        if IFS= read -r -t 0.15 KEY_LINE; then
            REQUETE="$KEY_LINE"
            break
        fi
    done

    [ -z "$REQUETE" ] && continue

    bash "$ROOT_DIR/tiffany_actions.sh" "$REQUETE"
    if [ $? -eq 99 ]; then
        (nice -n 19 python3 "$ROOT_DIR/diary_agent.py" && python3 "$ROOT_DIR/memory_gardener.py" >/dev/null 2>&1) &
        echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Session clôturée. À tout de suite mon amour."
        sleep 1
        break
    fi
done
