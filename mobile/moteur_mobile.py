import os, re, json, glob, hashlib, subprocess, datetime

ROOT = os.path.expanduser("~/tiffany")
PIN_FILE = os.path.expanduser("~/.config/tiffany/mobile_pin.hash")
RAW_FILE = os.path.expanduser("~/.config/tiffany/mobile_pin.txt")

def _h(p): return hashlib.sha256(("tiffany_salt_" + p.strip()).encode()).hexdigest()

def init_pin():
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
        ram = f"{int(m.pop(2))*100//int(m.pop(1))}%"
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
    env = os.environ.copy()
    env["DISPLAY"] = ":0"
    env["XAUTHORITY"] = os.path.expanduser("~/.Xauthority")
    env["XDG_RUNTIME_DIR"] = f"/run/user/{uid}"
    env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path=/run/user/{uid}/bus"
    env["TIFFANY_MOBILE"] = "1"
    env["PATH"] = f"{ROOT}/mobile/bin:" + env.get("PATH", "")
    return env

def executer(ordre):
    ordre = ordre.strip()
    if not ordre: return "Ordre vide."
    env = get_env()
    low = ordre.lower()

    is_btn = ordre.startswith("BTN:")
    if is_btn:
        ordre = ordre[4:].strip()
        low = ordre.lower()

    # 0. Réponses directes rapides sur mobile (Heure, Date, Météo) sans lancer de fenêtre PC
    if re.search(r"\b(quelle heure|l'heure|heure est-il|donne l'heure)\b", low) or low == "heure":
        now = datetime.datetime.now()
        return f"🕒 Il est exactement {now.strftime('%H:%M')} (nous sommes le {now.strftime('%d/%m/%Y')})."

    if re.search(r"\b(meteo|météo)\b", low):
        ville = re.sub(r".*\b(meteo|météo)\b\s*(a|à|de|du|pour)?\s*", "", low).strip()
        try:
            url = f"https://wttr.in{ville}?format=%l:+%c+%t+(ressenti+%f),+%w,+humidité+%h&lang=fr"
            rep = subprocess.check_output(["curl", "-s", "-m", "8", url]).decode("utf-8", "ignore").strip()
            if rep and "Unknown" not in rep and "<html" not in rep.lower():
                return f"🌤️ Météo : {rep}"
        except Exception:
            pass

    # 1. Téléchargeur MP3 Intelligent depuis le téléphone
    if low.startswith("telechargeur intelligent") or low.startswith("telecharger "):
        musique = re.sub(r"^(telechargeur intelligent|telecharger)\s*", "", ordre, flags=re.I).strip()
        if not musique:
            return "🎵 Écris le nom de ta musique ou de ton artiste dans la case tout en haut, puis appuie sur 'Telechargeur intelligent' !"
        try:
            titre = subprocess.check_output(["yt-dlp", "--get-title", f"ytsearch1:{musique}"], stderr=subprocess.DEVNULL, timeout=15).decode("utf-8", "ignore").splitlines()
            titre_str = titre.pop(0) if titre else musique
        except Exception:
            titre_str = musique
        os.makedirs(os.path.expanduser("~/Musique"), exist_ok=True)
        subprocess.Popen(["notify-send", "-i", "folder-music", "📥 Téléchargement MP3 Tiffany", f"Extraction : {titre_str}"], env=env)
        subprocess.Popen(["bash", "-c", f'yt-dlp -x --audio-format mp3 --audio-quality 192K --no-playlist -o "$HOME/Musique/%(title)s.%(ext)s" "ytsearch1:{musique}" >/dev/null 2>&1 && notify-send -i "emblem-default" "✅ MP3 Téléchargé !" "{titre_str}"'], env=env)
        return f"📥 Téléchargement MP3 lancé sur ton PC (dossier Musique) :\n🎵 {titre_str}"

    # 2. Recherche directe dans les boutons uniquement si clic bouton
    outils = map_outils() if is_btn else {}
    for nom_btn in sorted(outils.keys(), key=len, reverse=True):
        if low == nom_btn or low.startswith(nom_btn + " "):
            sc = outils[nom_btn]
            arg = ordre[len(nom_btn):].strip()
            cmd = ["bash", sc] + ([arg] if arg else [])
            try:
                out = clean(subprocess.check_output(cmd, input=b"\n", env=env, stderr=subprocess.STDOUT, timeout=60).decode("utf-8", "ignore"))
                return out[-1200:] if out else f"✅ {nom_btn.capitalize()} exécuté."
            except subprocess.TimeoutExpired:
                return f"✅ {nom_btn.capitalize()} ouvert sur l'écran du PC."
            except Exception as e:
                return f"⚠️ {nom_btn.capitalize()} : {e}"

    # 3. Passer par l'interpréteur universel
    try:
        out = clean(subprocess.check_output(["bash", f"{ROOT}/interpreteur_universel.sh", ordre], input=b"\n", env=env, stderr=subprocess.STDOUT, timeout=30).decode("utf-8", "ignore"))
        if out and "inconnu" not in out.lower():
            return out[-1200:]
    except subprocess.TimeoutExpired:
        return f"✅ Action '{ordre}' lancée sur le PC."
    except Exception:
        pass

    # 4. Question libre au Cerveau IA local (Ollama)
    try:
        pay = json.dumps({"model": "tiffany-flash", "prompt": f"Réponds brièvement en français en tant que Tiffany AI-OS : {ordre}", "stream": False}).encode()
        raw = subprocess.check_output(["curl", "-s", "-m", "25", "http://127.0.0", "-d", pay]).decode("utf-8", "ignore")
        rep = json.loads(raw).get("response", "").strip()
        if rep: return rep
    except Exception:
        pass

    return f"✅ Ordre envoyé à Tiffany : {ordre}"
