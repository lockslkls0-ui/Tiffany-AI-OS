#!/usr/bin/env bash
# TERM_KEY: ecoute
# TERM_DESC: Ecouter ta voix au micro (5s) et executer l ordre
# TERM_ICON: 🎤

MODEL_DIR="$HOME/tiffany/voice/vosk-fr/vosk-model-small-fr-0.22"
TMP_WAV="/tmp/tiffany_voix.wav"

if [ ! -d "$MODEL_DIR" ]; then
    echo "❌ Modèle vocal Vosk introuvable dans $MODEL_DIR"
    exit 1
fi

pactl set-source-mute @DEFAULT_SOURCE@ 0 2>/dev/null || true
amixer sset Capture cap 100% >/dev/null 2>&1 || true

notify-send -u low -t 4000 -i "audio-input-microphone" "🎤 Tiffany t'écoute..." "Parle maintenant (5 secondes)..." >/dev/null 2>&1
echo -e "\n\033[1;36m🎤 [Ouïe Active] Parle maintenant (5 secondes)...\033[0m"

# Enregistrement direct via arecord (16 kHz, 16-bit mono, format natif attendu par Vosk)
rm -f "$TMP_WAV"
arecord -d 5 -f S16_LE -r 16000 -c 1 -q "$TMP_WAV" 2>/dev/null

TEXTE_ENTENDU=$(python3 - "$MODEL_DIR" "$TMP_WAV" 2>/dev/null << 'PYEOF'
import sys, json, wave
from vosk import Model, KaldiRecognizer, SetLogLevel
SetLogLevel(-1)
wf = wave.open(sys.argv[2], "rb")
model = Model(sys.argv[1])
rec = KaldiRecognizer(model, wf.getframerate())
while True:
    data = wf.readframes(4000)
    if len(data) == 0:
        break
    rec.AcceptWaveform(data)
res = json.loads(rec.FinalResult())
print(res.get("text", "").strip())
PYEOF
)
rm -f "$TMP_WAV"

if [ -n "$TEXTE_ENTENDU" ]; then
    echo -e "\033[1;32m🗣️ Entendu :\033[0m \"$TEXTE_ENTENDU\"\n"
    bash "$HOME/tiffany/tiffany_actions.sh" "$TEXTE_ENTENDU"
else
    echo -e "\033[1;33m🔇 Aucune parole détectée (parle un peu plus fort près du micro ou branche un kit mains-libres).\033[0m\n"
fi
