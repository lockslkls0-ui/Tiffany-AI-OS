#!/usr/bin/env bash
ROOT_DIR="$HOME/tiffany"
MODEL_DIR="$ROOT_DIR/voice/vosk-fr/vosk-model-small-fr-0.22"
[ ! -d "$MODEL_DIR" ] && exit 1

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

pactl set-source-mute @DEFAULT_SOURCE@ 0 2>/dev/null || true
amixer sset Capture cap 100% >/dev/null 2>&1 || true

python3 - "$MODEL_DIR" "$ROOT_DIR" << 'PYEOF'
import sys, os, json, subprocess, time, shlex, struct, math
from vosk import Model, KaldiRecognizer, SetLogLevel

SetLogLevel(-1)
model_dir = sys.argv.__getitem__(1)
root_dir = sys.argv.__getitem__(2)
actions_script = os.path.join(root_dir, "tiffany_actions.sh")
core_script = os.path.join(root_dir, "tiffany_core.sh")

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
    "plein ecran", "verrouille", "oreille", "tais-toi", "chut", "eteins"
)

def volume_rms(data):
    count = len(data) // 2
    if count == 0:
        return 0
    shorts = struct.unpack(f"{count}h", data[:count*2])
    sum_sq = sum(s * s for s in shorts)
    return math.sqrt(sum_sq / count)

def parler(texte):
    subprocess.Popen(["espeak-ng", "-v", "fr+f5", "-s", "145", "-p", "85", texte], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def notifier(titre, msg):
    subprocess.Popen(["notify-send", "-u", "low", "-t", "3000", "-i", "audio-input-microphone", titre, msg], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

dernier_declenchement = 0

def executer_ordre(commande):
    global dernier_declenchement
    commande = commande.strip()
    if not commande:
        return
    # Verrou anti-mitraillette : 1 seule exécution toutes les 4 secondes max
    if time.time() - dernier_declenchement < 4.0:
        return
    dernier_declenchement = time.time()

    notifier("🌹 Tiffany (Voix Comprise)", "👉 " + commande)
    parler("Tout de suite : " + commande)

    cmd_low = commande.lower()
    if any(k in cmd_low for k in ACTIONS_SANS_TERMINAL):
        subprocess.Popen(["bash", actions_script, commande], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        safe_cmd = shlex.quote(commande)
        bash_cmd = f"bash {shlex.quote(actions_script)} {safe_cmd}; echo ''; bash {shlex.quote(core_script)}"
        subprocess.Popen(["gnome-terminal", "--title=🌹 Discussion Tiffany", "--", "bash", "-c", bash_cmd])

notifier("👂 Oreille Légère Active", "Mode éco-CPU activé : dis 'Tiffany' à tout moment !")

en_attente_suite = False
debut_attente = 0
silence_frames = 0

while True:
    data = proc.stdout.read(4000)
    if not data:
        time.sleep(0.1)
        continue

    # Filtre économique : si c'est du silence ambiant (RMS < 350), on ne réveille pas Vosk !
    rms = volume_rms(data)
    if rms < 350 and not en_attente_suite:
        silence_frames += 1
        if silence_frames == 8:
            rec.Reset()
        time.sleep(0.02)
        continue
    silence_frames = 0

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
        if en_attente_suite and (time.time() - debut_attente > 10):
            en_attente_suite = False
PYEOF
