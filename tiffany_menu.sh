#!/usr/bin/env bash
ROOT_DIR="$HOME/tiffany"
PLUGIN_DIR="$ROOT_DIR/plugins"
MEM_GEO="$HOME/.tiffany_menu_geo.txt"
[ -f "$MEM_GEO" ] || echo "0,400,200,580,660" > "$MEM_GEO"

POS_FILE="$HOME/tiffany/memory/panneau_position.txt"
(
    while pgrep -f "tiffany_menu.sh" >/dev/null 2>&1; do
        GEOM=$(wmctrl -lG 2>/dev/null | grep -i "Tiffany" | grep -v "Discussion" | head -n 1 | awk '{print "0," $3 "," $4 "," $5 "," $6}')
        [ -n "$GEOM" ] && echo "$GEOM" > "$POS_FILE"
        sleep 0.6
    done
) &
TRACK_PID=$!
trap "kill $TRACK_PID 2>/dev/null" EXIT

while true; do
    GEO_SAVED=$(cat "$MEM_GEO" 2>/dev/null)
    [[ "$GEO_SAVED" != 0,* ]] && GEO_SAVED="0,400,200,580,660"
    LAST_W=$(echo "$GEO_SAVED" | cut -d',' -f4)
    LAST_H=$(echo "$GEO_SAVED" | cut -d',' -f5)

    ZENITY_ARGS=()
    PLUGIN_FILES=()
    for script in $(ls "$PLUGIN_DIR"/*.sh 2>/dev/null | sort); do
        NAME=$(grep -m1 "# MENU_NAME:" "$script" | cut -d':' -f2- | sed 's/^[ \t]*//')
        DESC=$(grep -m1 "# MENU_DESC:" "$script" | cut -d':' -f2- | sed 's/^[ \t]*//')
        if [ -n "$NAME" ]; then
            ZENITY_ARGS+=("$NAME" "$DESC")
            PLUGIN_FILES+=("$script")
        fi
    done
    ZENITY_ARGS+=("❌ Quitter" "Fermer définitivement le menu")

    # Espion wmctrl sécurisé par ID de fenêtre unique (WID)
    (
        WID=""
        for i in {1..30}; do
            sleep 0.03
            WID=$(wmctrl -l 2>/dev/null | grep "TIFFANY_OS" | awk '{print $1}' | head -n 1)
            if [ -n "$WID" ]; then
                wmctrl -i -r "$WID" -e "$GEO_SAVED" 2>/dev/null
                break
            fi
        done
        sleep 0.4
        while [ -n "$WID" ]; do
            sleep 0.4
            LIGNE=$(wmctrl -lG 2>/dev/null | grep "^$WID ")
            [ -z "$LIGNE" ] && break
            GX=$(echo "$LIGNE" | awk '{print $3}')
            GY=$(echo "$LIGNE" | awk '{print $4}')
            GW=$(echo "$LIGNE" | awk '{print $5}')
            GH=$(echo "$LIGNE" | awk '{print $6}')
            GY_CORR=$((GY - 28))
            [ "$GY_CORR" -lt 0 ] && GY_CORR=0
            if [ -n "$GW" ] && [ "$GW" -gt 150 ]; then
                echo "0,$GX,$GY_CORR,$GW,$GH" > "$MEM_GEO"
            fi
        done
    ) &
    SPY_PID=$!

        (
        for _ in $(seq 1 20); do
            sleep 0.08
            if wmctrl -l 2>/dev/null | grep -i "Tiffany" | grep -qv "Discussion"; then
                [ -s "$POS_FILE" ] && wmctrl -r "Tiffany" -e "$(cat "$POS_FILE")" 2>/dev/null
                break
            fi
        done
    ) &
    CHOIX=$(zenity --list "${ZENITY_ARGS[@]}" --title="TIFFANY_OS" --column="Action" --column="Description" --width="$LAST_W" --height="$LAST_H" 2>/dev/null)
    CODE=$?
    kill $SPY_PID 2>/dev/null

    if [ $CODE -ne 0 ] || [ -z "$CHOIX" ] || [[ "$CHOIX" == "❌ Quitter" ]]; then break; fi
    for script in "${PLUGIN_FILES[@]}"; do
        NAME=$(grep -m1 "# MENU_NAME:" "$script" | cut -d':' -f2- | sed 's/^[ \t]*//')
        if [[ "$CHOIX" == "$NAME" ]]; then bash "$script" </dev/null >/dev/null 2>&1 & break; fi
    done
    sleep 0.05
done

