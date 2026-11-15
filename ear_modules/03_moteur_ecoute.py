import sys, os, json, subprocess, time, select, shlex, audioop, importlib.util
from vosk import Model, KaldiRecognizer, SetLogLevel
SetLogLevel(-1)
spec = importlib.util.spec_from_file_location("f", os.path.expanduser("~/tiffany/ear_modules/02_filtre_alias.py"))
filtre = importlib.util.module_from_spec(spec); spec.loader.exec_module(filtre)
ROOT = os.path.expanduser("~/tiffany")
BIN_SPEAK = os.path.join(ROOT, "bin/espeak-ng")
FIFO = "/tmp/tiffany_chat.fifo"
WAKE = ("tiffany","tifany","typhanie","stéphanie","tiff","tif","tife","typh","type","tifs","hey","ey","eh","ok tiffany")
STOP = ("arrête","arrete","arrêt","arret","arrêter","stop","stop ia","tais-toi","tais toi","chut","annule","coupe")
rec = KaldiRecognizer(Model(os.path.join(ROOT, "voice/vosk-fr/vosk-model-small-fr-0.22")), 16000)
def cap(): return subprocess.Popen(shlex.split("arecord -D pulse -f S16_LE -r 16000 -c 1 -t raw --buffer-size=8000 -q"), stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
def dire(t):
    global muet_jusqua; muet_jusqua = time.time() + 2.3
    cmd = BIN_SPEAK if os.path.exists(BIN_SPEAK) else "/usr/bin/espeak-ng"
    subprocess.Popen([cmd, "-v", "fr+f5", "-s", "145", "-p", "85", t], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    rec.Reset()
def notif(a,b): subprocess.Popen(["notify-send","-u","low","-t","2000",a,b], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
def stop_ia():
    for pat in ("curl.*11434","ollama run","piper"): subprocess.run(["pkill","-9","-f",pat], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.run(["pkill","-x","aplay"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if os.path.exists(FIFO):
        try: fd=os.open(FIFO,os.O_WRONLY|os.O_NONBLOCK); os.write(fd,b"stop\n"); os.close(fd)
        except Exception: pass
    notif("🛑 Tiffany", "Recherche IA stoppée !")
def envoi(c):
    if os.path.exists(FIFO):
        try: fd=os.open(FIFO,os.O_WRONLY|os.O_NONBLOCK); os.write(fd,(c+"\n").encode()); os.close(fd); return
        except Exception: pass
    subprocess.Popen(["gnome-terminal","--title=Discussion_Tiffany","--","bash",os.path.join(ROOT,"tiffany_core.sh")])
    for _ in range(25):
        time.sleep(0.1)
        if os.path.exists(FIFO):
            try: fd=os.open(FIFO,os.O_WRONLY|os.O_NONBLOCK); os.write(fd,(c+"\n").encode()); os.close(fd); break
            except Exception: pass
proc, der, att16, suite, deb, muet_jusqua = cap(), 0, 0, False, 0, 0
def ordre(b):
    global der, att16
    bl = b.strip().lower()
    if any(s==bl or bl.startswith(s+" ") or (" "+s) in bl for s in STOP): att16=0; stop_ia(); return
    if time.time()-der < 1.2: return
    ok, al = filtre.filtrer(bl)
    if not ok: return
    der, att16 = time.time(), time.time()+16.0
    notif("🌹 Tiffany", "👉 "+ok)
    if al or any(k in ok for k in filtre.ACT): subprocess.Popen(["bash",os.path.join(ROOT,"tiffany_actions.sh"),ok])
    else: envoi(ok)
notif("👂 Tiffany Prête", "Voix Siwis HD + CPU Éco + Anti-bruit")
while True:
    time.sleep(0.22)
    r,_,_ = select.select(list((proc.stdout,)),(),(),3.0)
    if not r: proc.kill(); proc.wait(); proc=cap(); rec.Reset(); continue
    d = proc.stdout.read(8000)
    if not d or proc.poll() is not None: proc.kill(); proc.wait(); time.sleep(0.5); proc=cap(); continue
    if time.time() < muet_jusqua:
        rec.Reset(); continue
    if audioop.rms(d, 2) < 110 and time.time() > att16 and not suite:
        time.sleep(0.05)
        continue
    if rec.AcceptWaveform(d):
        t = json.loads(rec.Result()).get("text","").strip().lower()
        if not t: continue
        if any(s==t or t.startswith(s+" ") for s in STOP): suite=False; att16=0; stop_ia(); continue
        if suite: suite=False; ordre(t); continue
        if time.time() < att16: ordre(t); continue
        for w in WAKE:
            if w in t.split() or t.startswith(w):
                c = t.split(w,1).pop(1).strip()
                if c: ordre(c)
                else: notif("🎤 Oui mon ange ?","16s..."); dire("Oui mon ange ?"); suite,deb,att16=True,time.time(),time.time()+16.0
                break
    elif suite and (time.time()-deb > 16): suite=False
