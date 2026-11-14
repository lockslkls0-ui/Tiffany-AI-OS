#!/usr/bin/env bash
export PATH="$HOME/tiffany/bin:$PATH"
ROOT_DIR="$HOME/tiffany"
MODEL_DIR="$ROOT_DIR/voice/vosk-fr/vosk-model-small-fr-0.22"
[ ! -d "$MODEL_DIR" ] && exit 1

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

armer_micro() {
    pactl unload-module module-echo-cancel >/dev/null 2>&1 || true
    VRAI_MICRO=$(pactl list short sources 2>/dev/null | awk '{print $2}' | grep -v "\.monitor" | head -n 1)
    [ -n "$VRAI_MICRO" ] && pactl set-default-source "$VRAI_MICRO" >/dev/null 2>&1 || true
    pactl set-source-mute @DEFAULT_SOURCE@ 0 >/dev/null 2>&1 || true
    pactl set-source-volume @DEFAULT_SOURCE@ 85% >/dev/null 2>&1 || true
    amixer sset "Internal Mic Boost" 50% >/dev/null 2>&1 || amixer sset "Mic Boost" 50% >/dev/null 2>&1 || true
    amixer sset Capture cap 75% >/dev/null 2>&1 || true
}

armer_micro

python3 - "$MODEL_DIR" "$ROOT_DIR" << 'PYEOF'
import sys, os, json, subprocess, time, select
from vosk import Model, KaldiRecognizer, SetLogLevel

SetLogLevel(-1)
model_dir = sys.argv.__getitem__(1)
root_dir = sys.argv.__getitem__(2)
actions_script = os.path.join(root_dir, "tiffany_actions.sh")
core_script = os.path.join(root_dir, "tiffany_core.sh")
fifo_path = "/tmp/tiffany_chat.fifo"

model = Model(model_dir)
rec = KaldiRecognizer(model, 16000)

def lancer_capture():
    return subprocess.Popen(
        ["arecord", "-D", "pulse", "-f", "S16_LE", "-r", "16000", "-c", "1", "-t", "raw", "-q"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL
    )

proc = lancer_capture()

WAKE_WORDS = ("tiffany", "tifany", "typhanie", "stéphanie", "tiff", "tif", "tife", "typh", "hey tiffany", "hey tiff", "hey", "ok tiffany")
ACTIONS_SANS_TERMINAL = (
    "next", "skip", "suivant", "suivante", "pause", "play", "stop", "muet", "silence",
    "musique", "radio", "menu", "panneau", "cam", "webcam", "zone",
    "nuit", "jour", "froid", "boost", "zram", "turbo", "backup", "sauvegarde",
    "instinct", "fenetre", "range", "bureau", "chrome", "youtube",
    "pilote", "droite", "gauche", "monte", "descends", "clic", "onglet",
    "plein ecran", "verrouille", "oreille", "tais-toi", "chut", "annule", "stop ia"
)

def parler_fluide(texte):
    subprocess.run(["espeak-ng", "-v", "fr+f5", "-s", "145", "-p", "85", texte], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    rec.Reset()

def notifier(titre, msg):
    subprocess.Popen(["notify-send", "-u", "low", "-t", "2500", "-i", "audio-input-microphone", titre, msg], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def envoyer_dans_fenetre_unique(commande):
    if os.path.exists(fifo_path):
        try:
            fd = os.open(fifo_path, os.O_WRONLY | os.O_NONBLOCK)
            os.write(fd, (commande + "\n").encode("utf-8"))
            os.close(fd)
            subprocess.Popen(["wmctrl", "-a", "Discussion Tiffany"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return
        except Exception:
            pass
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
attention_jusqua = 0

def executer_ordre(commande):
    global dernier_declenchement, attention_jusqua
    commande = commande.strip()
    if not commande or len(commande) <= 2 or (time.time() - dernier_declenchement < 1.5):
        return
    dernier_declenchement = time.time()
    attention_jusqua = time.time() + 16.0

    notifier("🌹 Tiffany", "👉 " + commande)
    cmd_low = commande.lower()
    if any(k in cmd_low for k in ACTIONS_SANS_TERMINAL):
        subprocess.Popen(["bash", actions_script, commande], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        envoyer_dans_fenetre_unique(commande)

notifier("👂 Oreille Pure Restaurée", "Dis 'Tiffany', 'Tiff' ou 'Hey' !")

en_attente_suite = False
debut_attente = 0

while True:
    rlist, _, _ = select.select([proc.stdout], [], [], 3.0)
    if not rlist:
        proc.kill()
        proc.wait()
        proc = lancer_capture()
        rec.Reset()
        continue

    data = proc.stdout.read(4000)
    if not data:
        proc.kill()
        proc.wait()
        time.sleep(0.2)
        proc = lancer_capture()
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

        if time.time() < attention_jusqua:
            executer_ordre(texte)
            continue

        for w in WAKE_WORDS:
            if w in texte.split() or texte.startswith(w):
                if w in texte:
                    avant, apres = texte.split(w, 1)
                    commande = apres.strip()
                    if commande:
                        executer_ordre(commande)
                    else:
                        notifier("🎤 Oui mon ange ?", "Dis ta phrase...")
                        parler_fluide("Oui mon ange ?")
                        en_attente_suite = True
                        debut_attente = time.time()
                    break
    else:
        if en_attente_suite and (time.time() - debut_attente > 16):
            en_attente_suite = False
PYEOF
