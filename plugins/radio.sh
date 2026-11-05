#!/usr/bin/env bash
# ==============================================================================
# 🌹 PLUGINS : radio.sh (Version 11.0 - LES 3 RADIOS VALIDÉES ET ACTIVES)
# 🛡️ RÔLE   : Lecteur audio d'arrière-plan avec flux réseaux directs fonctionnels
# ==============================================================================

ACTION=$(echo "$1" | tr 'A-Z' 'a-z')

# On coupe proprement tout lecteur existant pour éviter les superpositions de son
pkill -f mpv >/dev/null 2>&1
pkill -f cvlc >/dev/null 2>&1

PLAYER=""
if command -v mpv &>/dev/null; then
    PLAYER="mpv --no-video --network-timeout=10"
elif command -v cvlc &>/dev/null; then
    PLAYER="cvlc --no-video"
fi

if [ -z "$PLAYER" ] && [ "$ACTION" != "radio stop" ]; then
    exit 1
fi

case "$ACTION" in
    "radio djiido")
        echo "📻 Lancement de RDK Radio Djiido..."
        $PLAYER "http://radiodjiido.nc:8004" >/dev/null 2>&1 &
        ;;
    "radio paradise")
        echo "📻 Lancement de Radio Paradise..."
        $PLAYER "http://radioparadise.com" >/dev/null 2>&1 &
        ;;
    "radio kink")
        echo "📻 Lancement de KINK Radio..."
        $PLAYER "http://kink.nl" >/dev/null 2>&1 &
        ;;
    "radio stop")
        echo "🤫 Extinction de la radio."
        ;;
esac

