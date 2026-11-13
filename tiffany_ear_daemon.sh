#!/usr/bin/env bash
ROOT_DIR="$HOME/tiffany"
MODEL_DIR="$ROOT_DIR/voice/vosk-fr/vosk-model-small-fr-0.22"
[ ! -d "$MODEL_DIR" ] && exit 1

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

pactl set-source-mute @DEFAULT_SOURCE@ 0 2>/dev/null || true
amixer sset Capture cap 100% >/dev/null 2>&1 || true

python3 - "$MODEL_DIR" "$ROOT_DIR" << 'PYEOF'
import sys, os, json, re, subprocess, time
from vosk import Model, KaldiRecognizer, SetLogLevel

SetLogLevel(-1)
model_dir = sys.argv[1]
root_dir = sys.argv[2]
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
    notifier("🌹 Tiffany (Ordre Vocal)", f"Exécution : {commande}")
    subprocess.Popen(["bash", actions_script, commande], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

notifier("👂 Oreille Permanente Active", "Dis 'Tiffany [commande]' ou 'Tiffany écoute 8 secondes' !")

while True:
    data = proc.stdout.read(4000)
    if not data:
        time.sleep(0.1)
        continue
    if rec.AcceptWaveform(data):
        res = json.loads(rec.Result())
        texte = res.get("text", "").strip().lower()
        if not texte:
            continue

        declenche = False
        reste = texte
        for w in WAKE_WORDS:
            if w in texte:
                declenche = True
                reste = texte.split(w, 1)[1].strip()
                break

        if not declenche:
            continue

        m_sec = re.search(r"ecoute\w*\s*(\d+)?", reste.replace("é", "e"))
        if m_sec or reste == "":
            duree = int(m_sec.group(1)) if (m_sec and m_sec.group(1)) else 6
            duree = max(3, min(30, duree))
            notifier("🎤 Tiffany t'écoute...", f"Parle maintenant ({duree} secondes)...")
            frames_a_lire = int((16000 * 2 * duree) / 4000)
            rec_long = KaldiRecognizer(model, 16000)
            for _ in range(frames_a_lire):
                chunk = proc.stdout.read(4000)
                if chunk:
                    rec_long.AcceptWaveform(chunk)
            ordre_long = json.loads(rec_long.FinalResult()).get("text", "").strip()
            if ordre_long:
                executer_ordre(ordre_long)
        else:
            executer_ordre(reste)
PYEOF
