#!/usr/bin/env bash
ROOT_DIR="$HOME/tiffany"
MODEL_DIR="$ROOT_DIR/voice/vosk-fr/vosk-model-small-fr-0.22"
[ ! -d "$MODEL_DIR" ] && exit 1

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

pactl set-source-mute @DEFAULT_SOURCE@ 0 2>/dev/null || true
amixer sset Capture cap 100% >/dev/null 2>&1 || true

python3 - "$MODEL_DIR" "$ROOT_DIR" << 'PYEOF'
import sys, os, json, subprocess, time
from vosk import Model, KaldiRecognizer, SetLogLevel

SetLogLevel(-1)
model_dir = sys.argv.__getitem__(1)
root_dir = sys.argv.__getitem__(2)
actions_script = os.path.join(root_dir, "tiffany_actions.sh")

model = Model(model_dir)
rec = KaldiRecognizer(model, 16000)

proc = subprocess.Popen(
    ["arecord", "-f", "S16_LE", "-r", "16000", "-c", "1", "-t", "raw", "-q"],
    stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL
)

WAKE_WORDS = ("tiffany", "tifany", "typhanie", "stéphanie", "tiff", "téléphonie")

def parler(texte):
    subprocess.Popen(["espeak-ng", "-v", "fr+f5", "-s", "145", "-p", "85", texte], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def notifier(titre, msg):
    subprocess.Popen(["notify-send", "-u", "low", "-t", "3000", "-i", "audio-input-microphone", titre, msg], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def executer_ordre(commande):
    commande = commande.strip()
    if not commande:
        return
    notifier("🌹 Tiffany (Voix Comprise)", "👉 " + commande)
    parler("Tout de suite : " + commande)
    subprocess.Popen(["bash", actions_script, commande], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

notifier("👂 Tiffany à l'écoute", "Dis 'Tiffany' suivi de ta phrase à tout moment !")

en_attente_suite = False
debut_attente = 0

while True:
    data = proc.stdout.read(4000)
    if not data:
        time.sleep(0.05)
        continue

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
                avant, apres = texte.split(w, 1)
                commande = (apres.strip() if apres.strip() else avant.strip())
                if commande:
                    executer_ordre(commande)
                else:
                    notifier("🎤 Oui mon ange ?", "Je t'écoute, dis ta phrase...")
                    parler("Oui mon ange, je t'écoute.")
                    en_attente_suite = True
                    debut_attente = time.time()
                break
    else:
        if en_attente_suite and (time.time() - debut_attente > 12):
            en_attente_suite = False
PYEOF
