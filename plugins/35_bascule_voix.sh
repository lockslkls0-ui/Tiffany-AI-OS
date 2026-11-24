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
        if [ ! -s "$HOME/.config/tiffany/pro_license_disabled_launch" ]; then
            (
                MOD="$HOME/tiffany/voice/fr_FR-siwis-low.onnx"
                if [ -x "$HOME/tiffany/voice/piper" ] && [ -f "$MOD" ]; then
                    echo "Active l'édition Pro pour entendre ma vraie voix douce et mielleuse !" | "$HOME/tiffany/voice/piper" --model "$MOD" --output_raw 2>/dev/null | aplay -r 16000 -f S16_LE -t raw -q 2>/dev/null
                elif command -v piper >/dev/null 2>&1 && [ -f "$MOD" ]; then
                    echo "Active l'édition Pro pour entendre ma vraie voix douce et mielleuse !" | piper --model "$MOD" --output_raw 2>/dev/null | aplay -r 16000 -f S16_LE -t raw -q 2>/dev/null
                else
                    "$HOME/tiffany/bin/espeak-ng" "Active l'édition Pro pour entendre ma vraie voix douce et mielleuse !" >/dev/null 2>&1
                fi
            ) &
            zenity --question --title="💎 Option Édition PRO" --text="🌹 « Active le mode Pro pour entendre ma vraie voix douce et mielleuse ! »\n\nVoulez-vous entrer votre clé d'activation PRO maintenant ?" --width=440 2>/dev/null && bash "$HOME/tiffany/plugins/00c_activer_pro.sh"
            exit 0
        fi
        echo "piper" > "$MODE_FILE"
        ln -sf "$VOICE_DIR/fr_FR-siwis-low.onnx" "$VOICE_DIR/voix_active.onnx"
        ln -sf "$VOICE_DIR/fr_FR-siwis-low.onnx.json" "$VOICE_DIR/voix_active.onnx.json"
        "$HOME/tiffany/bin/espeak-ng" "Bonjour mon ange. Ma voix douce Siwis haute définition est activée et verrouillée." >/dev/null 2>&1 &
        zenity --info --text="🌹 Voix Douce Siwis HD activée et verrouillée pour tout le système !" --width=320 --timeout=2 2>/dev/null
        ;;
esac
