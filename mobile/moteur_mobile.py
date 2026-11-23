import os, re, json, glob, shutil, hashlib, subprocess, datetime

ROOT = os.path.expanduser("~/tiffany")
PIN_FILE = os.path.expanduser("~/.config/tiffany/mobile_pin.hash")
RAW_FILE = os.path.expanduser("~/.config/tiffany/mobile_pin.txt")

def _h(p): return hashlib.sha256(("tiffany_salt_" + p.strip()).encode()).hexdigest()

def init_pin():
    os.makedirs(os.path.dirname(PIN_FILE), exist_ok=True)
    if not os.path.exists(PIN_FILE):
        p = open(RAW_FILE).read().strip() if os.path.exists(RAW_FILE) else "1246"
        open(PIN_FILE, "w").write(_h(p))
    return open(RAW_FILE).read().strip() if os.path.exists(RAW_FILE) else "1246"

def check_pin(p): return os.path.exists(PIN_FILE) and _h(p) == open(PIN_FILE).read().strip()

def set_pin(np):
    np = np.strip()
    if len(np) < 4 or not np.isdigit(): return "❌ Minimum 4 chiffres."
    open(PIN_FILE, "w").write(_h(np)); open(RAW_FILE, "w").write(np)
    return "✅ Nouveau PIN enregistré !"

def stats():
    try:
        ts = [int(open(z).read())/1000.0 for z in glob.glob("/sys/class/thermal/thermal_zone*/temp") if 10000 < int(open(z).read()) < 120000]
        temp = f"{max(ts):.1f}°C" if ts else "N/A"
    except Exception: temp = "N/A"
    try:
        m = subprocess.check_output(["free", "-m"]).decode().splitlines().pop(1).split()
        ram = f"{int(m[2])*100//int(m[1])}%"
    except Exception: ram = "N/A"
    prompt = None
    if os.path.exists("/tmp/tiffany_mob_prompt.json"):
        try:
            prompt = json.load(open("/tmp/tiffany_mob_prompt.json", encoding="utf-8"))
        except Exception:
            pass
    return {"temp": temp, "ram": ram, "prompt": prompt}

def map_outils():
    mapping = {}
    for d in ("plugins", "actions_terminal"):
        for f in sorted(glob.glob(os.path.join(ROOT, d, "*.sh"))):
            b = os.path.basename(f)
            if b.endswith(".off"): continue
            nom = re.sub(r"^\d+[a-z]?_|^Z\d+_", "", b[:-3]).replace("_", " ").strip().lower()
            if nom and nom not in mapping:
                mapping[nom] = f
    return mapping

def lister_outils():
    return [(k.capitalize(), k) for k in map_outils().keys()]

def clean(s):
    return re.sub(r'\x1b\[[0-9;]*[a-zA-Z]', '', s).strip()

def get_env():
    uid = os.getuid()
    home = os.path.expanduser("~")
    env = os.environ.copy()
    env["DISPLAY"] = ":0"
    env["XAUTHORITY"] = os.path.join(home, ".Xauthority")
    env["XDG_RUNTIME_DIR"] = f"/run/user/{uid}"
    env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path=/run/user/{uid}/bus"
    env["TIFFANY_MOBILE"] = "1"
    env["PATH"] = f"{ROOT}/mobile/bin:{home}/.local/bin:/usr/local/bin:/usr/bin:/bin:" + env.get("PATH", "")
    return env

def find_ytdlp():
    for c in (os.path.expanduser("~/.local/bin/yt-dlp"), "/usr/local/bin/yt-dlp", "/usr/bin/yt-dlp", shutil.which("yt-dlp")):
        if c and os.path.isfile(c) and os.access(c, os.X_OK):
            return c
    return None


def sync_bureau_et_memoire(ordre, reponse=""):
    import time
    log_f = os.path.join(ROOT, "logs", "session_raw.txt")
    os.makedirs(os.path.dirname(log_f), exist_ok=True)
    horo = datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    with open(log_f, "a", encoding="utf-8") as f:
        f.write(f"[{horo}] USER (Mobile): {ordre}\n")
        if reponse:
            f.write(f"[{horo}] TIFFANY (Mobile): {reponse}\n")
    env = get_env()
    fifo = "/tmp/tiffany_chat.fifo"
    if not os.path.exists("/tmp/tiffany_core_ready") or not os.path.exists(fifo):
        if os.path.exists("/tmp/tiffany_core_ready"):
            try: os.remove("/tmp/tiffany_core_ready")
            except Exception: pass
        subprocess.Popen(["gnome-terminal", "--title=Discussion_Tiffany", "--", "bash", os.path.join(ROOT, "tiffany_core.sh")], env=env)
        for _ in range(40):
            time.sleep(0.1)
            if os.path.exists("/tmp/tiffany_core_ready") and os.path.exists(fifo):
                break
    if os.path.exists(fifo):
        try:
            fd = os.open(fifo, os.O_WRONLY | os.O_NONBLOCK)
            os.write(fd, (f"[📱 Mobile] {ordre}\n").encode("utf-8"))
            os.close(fd)
        except Exception:
            pass

def executer(ordre):
    ordre = ordre.strip()
    if not ordre: return "Ordre vide."
    env = get_env()
    low = ordre.lower()

    sync_bureau_et_memoire(ordre)
    if ordre.startswith("BTN:"):
        ordre = ordre[4:].strip()
        low = ordre.lower()

    # 1. Heure & Météo directes (sans lancer l'horloge Matrix)
    if re.search(r"\b(quelle heure|l'heure|heure est-il|donne l'heure)\b", low) or low == "heure":
        now = datetime.datetime.now()
        return f"🕒 Il est {now.strftime('%H:%M')} (le {now.strftime('%d/%m/%Y')})."

    if re.search(r"\b(meteo|météo)\b", low):
        ville = re.sub(r".*\b(meteo|météo)\b\s*(a|à|de|du|pour)?\s*", "", low).strip()
        try:
            rep = subprocess.check_output(["curl", "-s", "-m", "8", f"https://wttr.in{ville}?format=%l:+%c+%t+(ressenti+%f),+%w&lang=fr"]).decode("utf-8", "ignore").strip()
            if rep and "Unknown" not in rep and "<html" not in rep.lower():
                return f"🌤️ Météo : {rep}"
        except Exception:
            pass

    # 2. Téléchargeur MP3 (fonctionne avec les deux boutons + cherche yt-dlp partout)
    if low.startswith("telechargeur intelligent") or low.startswith("telecharger "):
        musique = re.sub(r"^(telechargeur mp3 pro|telechargeur intelligent|telecharger)\s*", "", ordre, flags=re.I).strip()
        if not musique:
            return "🎵 Écris le nom de ta musique dans la case en haut, puis appuie sur le bouton Téléchargeur !"
        yt = find_ytdlp()
        if not yt:
            return "❌ yt-dlp est introuvable sur le PC (installe-le avec : pip3 install yt-dlp)."
        try:
            titre_lines = subprocess.check_output([yt, "--no-update", "--get-title", f"ytsearch1:{musique}"], env=env, stderr=subprocess.DEVNULL, timeout=25).decode("utf-8", "ignore").splitlines()
            titre_str = titre_lines[0] if titre_lines else musique
        except Exception as e:
            return f"❌ Recherche YouTube impossible : {e}"
        os.makedirs(os.path.expanduser("~/Musique"), exist_ok=True)
        subprocess.Popen(["notify-send", "-i", "folder-music", "📥 Téléchargement MP3 Tiffany", f"Extraction : {titre_str}"], env=env)
        dl_cmd = (
            f'"{yt}" --no-update -x --audio-format mp3 --audio-quality 192K --no-playlist '
            f'-o "$HOME/Musique/%(title)s.%(ext)s" "ytsearch1:{musique}" >/tmp/tiffany_dl.log 2>&1 && '
            f'notify-send -i "emblem-default" "✅ MP3 Téléchargé !" "{titre_str}" && '
            f'F=$(ls -t "$HOME/Musique"/*.mp3 2>/dev/null | head -n 1) && '
            f'[ -n "$F" ] && (pgrep -x rhythmbox >/dev/null || nohup rhythmbox >/dev/null 2>&1 &) && sleep 2 && rhythmbox-client --enqueue "$F" >/dev/null 2>&1'
        )
        subprocess.Popen(["bash", "-c", dl_cmd], env=env)
        return f"📥 Téléchargement MP3 lancé :\n🎵 {titre_str}\n(Ajout automatique à Rhythmbox dès la fin)"

    # 3. Boutons & Outils (correspondance exacte ou mot-clé comme 'boost' / 'froid')
    outils = map_outils()
    for nom_btn in sorted(outils.keys(), key=len, reverse=True):
        if low == nom_btn or low.startswith(nom_btn + " ") or (len(low) >= 4 and low in nom_btn):
            sc = outils[nom_btn]
            arg = ordre[len(nom_btn):].strip() if low.startswith(nom_btn) else ""
            cmd = ["bash", sc] + ([arg] if arg else [])
            try:
                out = clean(subprocess.check_output(cmd, input=b"\n", env=env, stderr=subprocess.STDOUT, timeout=30).decode("utf-8", "ignore"))
                return out[-1200:] if out else f"✅ {nom_btn.capitalize()} exécuté."
            except subprocess.TimeoutExpired:
                return f"✅ {nom_btn.capitalize()} ouvert."
            except Exception as e:
                return f"⚠️ {nom_btn.capitalize()} : {e}"

    # 4. Interpréteur universel
    try:
        out = clean(subprocess.check_output(["bash", f"{ROOT}/tiffany_actions.sh", ordre], input=b"\n", env=env, stderr=subprocess.STDOUT, timeout=20).decode("utf-8", "ignore"))
        if out and "inconnu" not in out.lower():
            return out[-1200:]
    except subprocess.TimeoutExpired:
        return f"✅ Action '{ordre}' lancée."
    except Exception:
        pass

    # 5. Cerveau IA local Ollama
    try:
        pay = json.dumps({"model": "tiffany-flash", "prompt": f"Réponds brièvement en français en tant que Tiffany AI-OS : {ordre}", "stream": False}).encode()
        raw = subprocess.check_output(["curl", "-s", "-m", "25", "http://127.0.0", "-d", pay]).decode("utf-8", "ignore")
        rep = json.loads(raw).get("response", "").strip()
        if rep: return rep
    except Exception:
        pass

    return f"✅ Ordre envoyé à Tiffany : {ordre}"
