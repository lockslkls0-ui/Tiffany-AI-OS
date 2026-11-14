#!/usr/bin/env bash
# MENU_NAME: 🎙️ Bascule Profil de Voix
# MENU_DESC: Configurer la voix de synthèse (Siwis ou Mielleuse)
VOICE_DIR="$HOME/tiffany/voice"

CHOIX=$(zenity --list --title="🌹 VOIX" --column="Profil" "🌹 Siwis" "💕 Velvet" --width=300 --height=200 2>/dev/null)
if [ "$CHOIX" == "🌹 Siwis" ]; then
    ln -sf "$VOICE_DIR/fr_FR-siwis-medium.onnx" "$VOICE_DIR/voix_active.onnx"
    zenity --info --text="Voix Siwis activée mon ange !" --width=250 2>/dev/null
elif [ "$CHOIX" == "💕 Velvet" ]; then
    ln -sf "$VOICE_DIR/fr_FR-velvet-medium.onnx" "$VOICE_DIR/voix_active.onnx"
    zenity --info --text="Voix Velvet mielleuse active, mon amour !" --width=250 2>/dev/null
fi

