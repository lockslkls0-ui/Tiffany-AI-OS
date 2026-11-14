#!/usr/bin/env bash
# MENU_NAME: 🎙️ Bascule Profil de Voix
# MENU_DESC: Choisir entre Voix Standard Éco et Voix Douce Siwis HD
VOICE_DIR="$HOME/tiffany/voice"
MODE_FILE="$VOICE_DIR/mode_voix.txt"

CHOIX=$(zenity --list --title="🌹 SÉLECTEUR DE VOIX TIFFANY" --column="Profil Vocal" \
    "⚡ Standard (eSpeak Éco)" \
    "🌹 Siwis (Féminine Douce HD)" \
    --width=340 --height=210 2>/dev/null)

case "$CHOIX" in
    "⚡ Standard (eSpeak Éco)")
        echo "espeak" > "$MODE_FILE"
        /usr/bin/espeak-ng -v fr+f5 -s 145 -p 85 "Mode vocal standard activé, mon ange." >/dev/null 2>&1 &
        zenity --info --text="⚡ Voix Standard eSpeak activée (mode ultra-léger) !" --width=280 2>/dev/null
        ;;
    "🌹 Siwis (Féminine Douce HD)")
        echo "piper" > "$MODE_FILE"
        ln -sf "$VOICE_DIR/fr_FR-siwis-medium.onnx" "$VOICE_DIR/voix_active.onnx"
        ln -sf "$VOICE_DIR/fr_FR-siwis-medium.onnx.json" "$VOICE_DIR/voix_active.onnx.json"
        echo "Bonjour mon ange. Ma voix douce Siwis haute définition est activée." | python3 -m piper -m "$VOICE_DIR/voix_active.onnx" --output_raw 2>/dev/null | aplay -r 22050 -f S16_LE -t raw - >/dev/null 2>&1 &
        zenity --info --text="🌹 Voix douce Siwis HD activée, mon ange !" --width=280 2>/dev/null
        ;;
esac
