#!/usr/bin/env bash
# TERM_KEY: ecoute
# TERM_DESC: Ecouter ta voix au micro (5s) et executer l ordre
# TERM_ICON: 🎤

MODEL_DIR="$HOME/tiffany/voice/vosk-fr/vosk-model-small-fr-0.22"
if [ ! -d "$MODEL_DIR" ]; then
    echo "❌ Modèle vocal Vosk introuvable dans $MODEL_DIR"
    exit 1
fi

notify-send -u low -t 4000 -i "audio-input-microphone" "🎤 Tiffany t'écoute..." "Parle maintenant (5 secondes)..." >/dev/null 2>&1
echo -e "\n\033[1;36m🎤 [Ouïe Active] Parle maintenant (5 secondes)...\033[0m"

TEXTE_ENTENDU=$(python3 - "$MODEL_DIR" 2>/dev/null << 'PYEOF'
import sys, json, pyaudio
from vosk import Model, KaldiRecognizer, SetLogLevel
SetLogLevel(-1)
model = Model(sys.argv)
rec = KaldiRecognizer(model, 16000)
p = pyaudio.PyAudio()
stream = p.open(format=pyaudio.paInt16, channels=1, rate=16000, input=True, frames_per_buffer=4096)
stream.start_stream()
for _ in range(0, int(16000 / 4096 * 5)):
    data = stream.read(4096, exception_on_overflow=False)
    rec.AcceptWaveform(data)
res = json.loads(rec.FinalResult())
print(res.get("text", "").strip())
stream.stop_stream(); stream.close(); p.terminate()
PYEOF
)

if [ -n "$TEXTE_ENTENDU" ]; then
    echo -e "\033[1;32m🗣️ Entendu :\033[0m \"$TEXTE_ENTENDU\"\n"
    bash "$HOME/tiffany/tiffany_actions.sh" "$TEXTE_ENTENDU"
else
    echo -e "\033[1;33m🔇 Aucune parole détectée (vérifie que ton micro n'est pas muet).\033[0m\n"
fi
