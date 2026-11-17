#!/usr/bin/env bash
# MENU_NAME: 🎙️ Bascule Profil de Voix
# MENU_DESC: Choisir entre Voix Légère (Vive) et Voix Douce Siwis HD (verrouillé)
VOICE_DIR="$HOME/tiffany/voice"
MODE_FILE="$VOICE_DIR/mode_voix.txt"
mkdir -p "$VOICE_DIR"

ACTUEL=$(cat "$MODE_FILE" 2>/dev/null | tr -d '[:space:]')
[ "$ACTUEL" = "espeak" ] && ETAT="Voix Légère (Vive)" || ETAT="Voix Douce Siwis HD"

CHOIX=$(zenity --list --title="🌹 SÉLECTEUR DE VOIX TIFFANY" \
    --text="Profil vocal actuellement verrouillé : $ETAT" \
    --column="Profil Vocal" \
    "⚡ Voix Légère (eSpeak Éco, Vive & Pétillante)" \
    "🌹 Voix Douce (Siwis HD Mielleuse)" \
    --width=380 --height=230 2>/dev/null)

case "$CHOIX" in
    "⚡ Voix Légère (eSpeak Éco, Vive & Pétillante)")
        echo "espeak" > "$MODE_FILE"
        "$HOME/tiffany/bin/espeak-ng" "Voix légère et pétillante activée et verrouillée, mon ange." >/dev/null 2>&1 &
        zenity --info --text="⚡ Voix Légère activée et verrouillée pour tout le système !" --width=320 --timeout=2 2>/dev/null
        ;;
    "🌹 Voix Douce (Siwis HD Mielleuse)")
        echo "piper" > "$MODE_FILE"
        ln -sf "$VOICE_DIR/fr_FR-siwis-low.onnx" "$VOICE_DIR/voix_active.onnx"
        ln -sf "$VOICE_DIR/fr_FR-siwis-low.onnx.json" "$VOICE_DIR/voix_active.onnx.json"
        "$HOME/tiffany/bin/espeak-ng" "Bonjour mon ange. Ma voix douce Siwis haute définition est activée et verrouillée." >/dev/null 2>&1 &
        zenity --info --text="🌹 Voix Douce Siwis HD activée et verrouillée pour tout le système !" --width=320 --timeout=2 2>/dev/null
        ;;
esac
