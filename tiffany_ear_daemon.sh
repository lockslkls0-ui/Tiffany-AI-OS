#!/usr/bin/env bash
ROOT_DIR="$HOME/tiffany"
MODEL_DIR="$ROOT_DIR/voice/vosk-fr/vosk-model-small-fr-0.22"
[ ! -d "$MODEL_DIR" ] && exit 1

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Activer le micro et le filtre anti-bruit WebRTC automatiquement
pactl set-source-mute @DEFAULT_SOURCE@ 0 2>/dev/null || true
amixer sset Capture cap 100% >/dev/null 2>&1 || true
pactl list short modules | grep -q "tiffany_clean_mic" || pactl load-module module-echo-cancel aec_method=webrtc source_name=tiffany_clean_mic >/dev/null 2>&1
pactl set-default-source tiffany_clean_mic >/dev/null 2>&1 || true

python3 - "$MODEL_DIR" "$ROOT_DIR" << 'PYEOF'
import sys, os, json, subprocess, time
from vosk import Model, KaldiRecognizer, SetLogLevel

SetLogLevel(-1)
model_dir = sys.argv
root_dir = sys.argv
actions_script = os.path.join(root_dir, "tiffany_actions.sh")

model = Model(model_dir)
rec = KaldiRecognizer(model, 16000)

proc = subprocess.Popen(
    ["arecord", "-f", "S16_LE", "-r", "16000", "-c", "1", "-t", "raw", "-q"],
    stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL
)

WAKE_WORDS = ("tiffany", "tiff", "stéphanie", "tifany")

def notifier(titre, msg):
    subprocess.Popen(["notify-send", "-u", "low", "-t", "3000", "-i", "audio-input-microphone", titre, msg], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def executer_ordre(commande):
    commande = commande.strip()
    if not commande:
        return
    notifier("🌹 Tiffany (Voix Comprise)", f"👉 {commande}")
    subprocess.Popen(["bash", actions_script, commande], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

notifier("👂 Tiffany à l'écoute", "Dis 'Tiffany' suivi de ta phrase à tout moment !")

en_attente_suite = False
debut_attente = 0

while True:
    data = proc.stdout.read(4000)
    if not data:
        time.sleep(0.05)
        continue

    # AcceptWaveform devient True automatiquement dès que tu fais une pause de ~1 seconde après ta phrase
    if rec.AcceptWaveform(data):
        res = json.loads(rec.Result())
        texte = res.get("text", "").strip().lower()

        if en_attente_suite:
            en_attente_suite = False
            if texte:
                executer_ordre(texte)
            continue

        if not texte:
            continue

        for w in WAKE_WORDS:
            if w in texte:
                reste = texte.split(w, 1).strip()
                if reste:
                    # Tu as dit "Tiffany [ta phrase]" d'un seul trait : exécution immédiate !
                    executer_ordre(reste)
                else:
                    # Tu as dit juste "Tiffany" : elle attend la suite de ta phrase jusqu'au prochain silence
                    notifier("🎤 Oui mon ange ?", "Je t'écoute, dis ta phrase...")
                    en_attente_suite = True
                    debut_attente = time.time()
                break
    else:
        if en_attente_suite and (time.time() - debut_attente > 12):
            en_attente_suite = False
PYEOF
