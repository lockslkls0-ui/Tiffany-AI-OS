#!/usr/bin/env bash
ROOT_DIR="$HOME/tiffany"
PLUGIN_DIR="$ROOT_DIR/plugins"
MEM_GEO="$HOME/.tiffany_menu_geo.txt"
if [ ! -f "$MEM_GEO" ]; then echo "400 200 580 660" > "$MEM_GEO"; fi
while true; do
    read -r LAST_X LAST_Y LAST_W LAST_H < "$MEM_GEO"
    [ -z "$LAST_W" ] && LAST_W=580; [ -z "$LAST_H" ] && LAST_H=660
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
    (
        for i in {1..10}; do
            sleep 0.01
            WID=$(xdotool search --name "TIFFANY_OS" 2>/dev/null | head -n 1)
            if [ -n "$WID" ]; then
                xdotool windowsize "$WID" "$LAST_W" "$LAST_H"
                xdotool windowmove "$WID" "$LAST_X" "$LAST_Y"
                break
            fi
        done
    ) &
    CHOIX=$(zenity --list "${ZENITY_ARGS[@]}" --title="TIFFANY_OS" --column="Action" --column="Description" --width="$LAST_W" --height="$LAST_H" 2>/dev/null)
    WID_CUR=$(xdotool search --name "TIFFANY_OS" 2>/dev/null | head -n 1)
    if [ -n "$WID_CUR" ]; then
        eval $(xdotool getwindowgeometry --shell "$WID_CUR" 2>/dev/null)
        if [ -n "$X" ] && [ -n "$Y" ] && [ -n "$WIDTH" ] && [ -n "$HEIGHT" ]; then echo "$X $Y $WIDTH $HEIGHT" > "$MEM_GEO"; fi
    fi
    if [ $? -ne 0 ] || [ -z "$CHOIX" ] || [[ "$CHOIX" == "❌ Quitter" ]]; then break; fi
    for script in "${PLUGIN_FILES[@]}"; do
        NAME=$(grep -m1 "# MENU_NAME:" "$script" | cut -d':' -f2- | sed 's/^[ \t]*//')
        if [[ "$CHOIX" == "$NAME" ]]; then bash "$script" </dev/null >/dev/null 2>&1 & break; fi
    done
    sleep 0.05
done
