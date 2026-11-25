#!/usr/bin/env bash
TEMP=0
for z in /sys/class/thermal/thermal_zone*/temp; do
    if [ -r "$z" ]; then
        VAL=$(cat "$z" 2>/dev/null)
        [ "$VAL" -gt 1000 ] 2>/dev/null && VAL=$((VAL / 1000))
        [ "$VAL" -gt "$TEMP" ] && [ "$VAL" -lt 125 ] && TEMP=$VAL
    fi
done
if [ "$TEMP" -eq 0 ] && command -v sensors >/dev/null 2>&1; then
    TEMP=$(sensors 2>/dev/null | grep -oE '\+[0-9]+\.[0-9]+°C' | head -n 1 | tr -d '+°C' | cut -d. -f1)
fi
[ -z "$TEMP" ] || [ "$TEMP" -eq 0 ] && TEMP=45
echo "$TEMP"
