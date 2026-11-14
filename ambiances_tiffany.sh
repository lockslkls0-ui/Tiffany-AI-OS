#!/usr/bin/env bash
Q="$1"
ROOT_DIR="$HOME/tiffany"
MODE_FILE="$ROOT_DIR/memory/ambiance_active.txt"
[ -f "$MODE_FILE" ] || echo "complice" > "$MODE_FILE"
NOM=$(cat "$ROOT_DIR/memory/surnom_utilisateur.txt" 2>/dev/null || echo "$USER")

dire_alea() {
    local ITEMS=("$@")
    local CHOIX="${ITEMS[$RANDOM % ${#ITEMS[@]}]}"
    local DEBIT=145
    [ "$(cat "$MODE_FILE" 2>/dev/null)" == "zen" ] && DEBIT=128
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m $CHOIX\n"
    pkill -x espeak-ng >/dev/null 2>&1
    (espeak-ng -v fr+f5 -s "$DEBIT" -p 85 "$(echo "$CHOIX" | tr -d '🌹⚡👑🧘💼')" >/dev/null 2>&1) &
    exit 0
}

if [[ "$Q" =~ ^(mode pro|ambiance pro|sois professionnelle|mode travail)$ ]]; then
    echo "pro" > "$MODE_FILE"
    dire_alea "Mode Professionnel activé, $NOM. Réponses directes, sobres et efficaces. 💼"
elif [[ "$Q" =~ ^(mode zen|ambiance zen|mode calme|detends toi)$ ]]; then
    echo "zen" > "$MODE_FILE"
    dire_alea "Mode Zen activé, $NOM... Je ralentis le rythme et j'apaise ma voix. 🧘"
elif [[ "$Q" =~ ^(mode complice|ambiance complice|mode normal|sois naturelle)$ ]]; then
    echo "complice" > "$MODE_FILE"
    dire_alea "Mode Complice activé, $NOM ! Toujours à tes côtés avec énergie. 🌹"
fi
exit 1
