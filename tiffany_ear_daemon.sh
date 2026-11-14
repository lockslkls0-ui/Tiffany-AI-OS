#!/usr/bin/env bash
ROOT_DIR="$HOME/tiffany"
MODEL_DIR="$ROOT_DIR/voice/vosk-fr/vosk-model-small-fr-0.22"
[ ! -d "$MODEL_DIR" ] && exit 1

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

pactl set-source-mute @DEFAULT_SOURCE@ 0 2>/dev/null || true
amixer sset Capture cap 100% >/dev/null 2>&1 || true

python3 - "$MODEL_DIR" "$ROOT_DIR" << 'PYEOF'
import sys, os, json, subprocess, time, struct, math
from vosk import Model, KaldiRecognizer, SetLogLevel

SetLogLevel(-1)
model_dir = sys.argv.__getitem__(1)
root_dir = sys.argv.__getitem__(2)
actions_script = os.path.join(root_dir, "tiffany_actions.sh")
core_script = os.path.join(root_dir, "tiffany_core.sh")
fifo_path = "/tmp/tiffany_chat.fifo"

model = Model(model_dir)
rec = KaldiRecognizer(model, 16000)

proc = subprocess.Popen(
    ["arecord", "-f", "S16_LE", "-r", "16000", "-c", "1", "-t", "raw", "-q"],
    stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL
)

WAKE_WORDS = ("tiffany", "tifany", "typhanie", "stéphanie", "tiff", "téléphonie")
ACTIONS_SANS_TERMINAL = (
    "next", "skip", "suivant", "pause", "play", "stop", "muet", "silence",
    "musique", "radio", "menu", "panneau", "cam", "webcam", "zone",
    "nuit", "jour", "froid", "boost", "zram", "turbo", "backup", "sauvegarde",
    "instinct", "fenetre", "range", "bureau", "chrome", "youtube",
    "pilote", "droite", "gauche", "monte", "descends", "clic", "onglet",
    "plein ecran", "verrouille", "oreille", "tais-toi", "chut", "annule", "stop ia", "eteins"
)

def volume_rms(data):
    count = len(data) // 2
    if count == 0:
        return 0
    shorts = struct.unpack(f"{count}h", data[:count*2])
    return math.sqrt(sum(s * s for s in shorts) / count)

def parler_fluide(texte):
    # Parle en priorité normale (pas bridé) et attend la fin pour ne pas s'écouter elle-même
    subprocess.run(["espeak-ng", "-v", "fr+f5", "-s", "145", "-p", "85", texte], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    rec.Reset()

def notifier(titre, msg):
    subprocess.Popen(["notify-send", "-u", "low", "-t", "2500", "-i", "audio-input-microphone", titre, msg], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def envoyer_dans_fenetre_unique(commande):
    # Si la fenêtre de discussion est déjà ouverte (FIFO présent), écrit directement dedans !
    if os.path.exists(fifo_path):
        try:
            fd = os.open(fifo_path, os.O_WRONLY | os.O_NONBLOCK)
            os.write(fd, (commande + "\n").encode("utf-8"))
            os.close(fd)
            subprocess.Popen(["wmctrl", "-a", "Discussion Tiffany"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return
        except Exception:
            pass
    # Sinon ouvre UNE seule fenêtre et y envoie la commande
    subprocess.Popen(["gnome-terminal", "--title=🌹 Discussion Tiffany", "--", "bash", core_script])
    for _ in range(25):
        time.sleep(0.1)
        if os.path.exists(fifo_path):
            try:
                fd = os.open(fifo_path, os.O_WRONLY | os.O_NONBLOCK)
                os.write(fd, (commande + "\n").encode("utf-8"))
                os.close(fd)
                break
            except Exception:
                pass

dernier_declenchement = 0

def executer_ordre(commande):
    global dernier_declenchement
    commande = commande.strip()
    if not commande or (time.time() - dernier_declenchement < 3.0):
        return
    dernier_declenchement = time.time()

    notifier("🌹 Tiffany", "👉 " + commande)
    cmd_low = commande.lower()
    if any(k in cmd_low for k in ACTIONS_SANS_TERMINAL):
        subprocess.Popen(["bash", actions_script, commande], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        envoyer_dans_fenetre_unique(commande)

notifier("👂 Oreille Synchronisée", "Fenêtre unique + voix fluide actives !")

en_attente_suite = False
debut_attente = 0

while True:
    data = proc.stdout.read(4000)
    if not data:
        time.sleep(0.05)
        continue

    if volume_rms(data) < 550 and not en_attente_suite:
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
                    notifier("🎤 Oui mon ange ?", "Dis ta phrase...")
                    parler_fluide("Oui mon ange ?")
                    en_attente_suite = True
                    debut_attente = time.time()
                break
    else:
        if en_attente_suite and (time.time() - debut_attente > 10):
            en_attente_suite = False
PYEOF
