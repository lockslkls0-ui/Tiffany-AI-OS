import os, re, json, glob, time, hashlib, subprocess, datetime

ROOT = os.path.expanduser("~/tiffany")
PIN_FILE = os.path.expanduser("~/.config/tiffany/mobile_pin.hash")
RAW_FILE = os.path.expanduser("~/.config/tiffany/mobile_pin.txt")
FIFO = "/tmp/tiffany_chat.fifo"

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
        try: prompt = json.load(open("/tmp/tiffany_mob_prompt.json", encoding="utf-8"))
        except Exception: pass
    return {"temp": temp, "ram": ram, "prompt": prompt}

def map_outils():
    mapping = {}
    for d in ("plugins", "actions_terminal"):
        for f in sorted(glob.glob(os.path.join(ROOT, d, "*.sh"))):
            b = os.path.basename(f)
            if b.endswith(".off"): continue
            nom = re.sub(r"^\d+[a-z]?_|^Z\d+_", "", b[:-3]).replace("_", " ").strip().lower()
            if nom and nom not in mapping: mapping[nom] = f
    return mapping

def lister_outils():
    return [(k.capitalize(), k) for k in map_outils().keys()]

def clean(s):
    s = re.sub(r'\x1b\[[0-9;]*[a-zA-Z]', '', s)
    return "\n".join(l.rstrip() for l in s.splitlines() if l.strip()).strip()

def get_env(force_pc_gui=True):
    uid = os.getuid()
    home = os.path.expanduser("~")
    env = os.environ.copy()
    env["DISPLAY"] = ":0"
    env["XAUTHORITY"] = os.path.join(home, ".Xauthority")
    env["XDG_RUNTIME_DIR"] = f"/run/user/{uid}"
    env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path=/run/user/{uid}/bus"
    if force_pc_gui:
        env.pop("TIFFANY_MOBILE", None)
        env["PATH"] = f"{ROOT}/bin:{home}/.local/bin:/usr/local/bin:/usr/bin:/bin"
    else:
        env["TIFFANY_MOBILE"] = "1"
        env["PATH"] = f"{ROOT}/mobile/bin:{ROOT}/bin:{home}/.local/bin:/usr/local/bin:/usr/bin:/bin"
    return env

def synchroniser_ecran_pc(ordre, reponse):
    log_f = os.path.join(ROOT, "logs", "session_raw.txt")
    mirror_f = "/tmp/tiffany_live_mirror.log"
    os.makedirs(os.path.dirname(log_f), exist_ok=True)
    horo = datetime.datetime.now().strftime("%H:%M:%S")
    horo_full = datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    with open(log_f, "a", encoding="utf-8") as f:
        f.write(f"[{horo_full}] USER (Mobile): {ordre}\n")
        if reponse: f.write(f"[{horo_full}] TIFFANY (Mobile): {reponse}\n")
    with open(mirror_f, "a", encoding="utf-8") as mf:
        mf.write(f"\n[{horo}] 📱 MOBILE : {ordre}\n[{horo}] 🌹 TIFFANY :\n{reponse}\n" + "-"*50 + "\n")

    env = get_env(force_pc_gui=True)
    wins = subprocess.getoutput("DISPLAY=:0 wmctrl -l 2>/dev/null")
    # Ouvre automatiquement la console Discussion_Tiffany sur le PC si fermée
    if "Suivi_Mobile_Tiffany" not in wins:
        subprocess.Popen([
            "gnome-terminal", "--title=Suivi_Mobile_Tiffany", "--",
            "bash", "-c", "clear; echo '🌹 SUIVI EN DIRECT — TELEPHONE <-> TIFFANY'; tail -n 30 -f /tmp/tiffany_live_mirror.log"
        ], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if "Discussion_Tiffany" not in wins:
        subprocess.Popen([
            "gnome-terminal", "--title=Discussion_Tiffany", "--",
            "bash", os.path.join(ROOT, "tiffany_core.sh")
        ], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def run_action(cmd_list, env, timeout=30):
    tmp_out = f"/tmp/tiff_mob_{os.getpid()}_{int(time.time()*1000)}.out"
    with open(tmp_out, "w", encoding="utf-8") as fout:
        p = subprocess.Popen(cmd_list, stdin=subprocess.DEVNULL, stdout=fout, stderr=subprocess.STDOUT, env=env, start_new_session=True)
        try:
            p.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            pass
    res = ""
    if os.path.exists(tmp_out):
        res = clean(open(tmp_out, encoding="utf-8", errors="ignore").read())
        try: os.remove(tmp_out)
        except Exception: pass
    return res if res else None

def executer(ordre):
    ordre_brut = ordre.strip()
    if not ordre_brut: return "Ordre vide."
    env_pc = get_env(force_pc_gui=True)
    is_btn = ordre_brut.startswith("BTN:")
    ordre = ordre_brut[4:].strip() if is_btn else ordre_brut
    low = ordre.lower()

    # 1. Actions matérielles & multimédia critiques (exécution immédiate + pop-up PC)
    if re.search(r"\b(boost|mode boost|pleine puissance|accelere)\b", low):
        subprocess.Popen(["bash", os.path.join(ROOT, "plugins/12_mode_boost.sh")], env=env_pc, start_new_session=True)
        mhz = subprocess.getoutput("awk -F': ' '/cpu MHz/{print int($2); exit}' /proc/cpuinfo")
        rep = f"⚡ Mode Boost activé sur le PC ! (Cadence : {mhz} MHz)."
        synchroniser_ecran_pc(ordre, rep)
        return rep

    if re.search(r"\b(froid|mode froid|refroidis|ca chauffe|trop chaud)\b", low):
        subprocess.Popen(["bash", os.path.join(ROOT, "plugins/11_mode_froid.sh")], env=env_pc, start_new_session=True)
        mhz = subprocess.getoutput("awk -F': ' '/cpu MHz/{print int($2); exit}' /proc/cpuinfo")
        rep = f"❄️ Mode Froid activé sur le PC ! (Cadence : {mhz} MHz)."
        synchroniser_ecran_pc(ordre, rep)
        return rep

    if re.search(r"\b(rhythmbox|musique|playlist|play music|play musique)\b", low) and not re.search(r"\b(stop|coupe|arrete|pause|next|suivant)\b", low):
        subprocess.Popen(["bash", os.path.join(ROOT, "plugins/43_allumer_rhythmbox.sh")], env=env_pc, start_new_session=True)
        rep = "🎵 Rhythmbox allumé et lecture de ta playlist lancée sur le PC !"
        synchroniser_ecran_pc(ordre, rep)
        return rep

    if "telechargeur mp3 pro" in low:
        subprocess.Popen(["bash", os.path.expanduser("~/.local/bin/telechargeur_mp3_pro.sh")], env=env_pc, start_new_session=True)
        rep = "🎧 Téléchargeur MP3 Pro ouvert sur l'écran du PC !"
        synchroniser_ecran_pc(ordre, rep)
        return rep

    if "telechargeur intelligent" in low or "telechargeur mp3" in low:
        subprocess.Popen(["bash", os.path.join(ROOT, "plugins/42_telechargeur_intelligent.sh")], env=env_pc, start_new_session=True)
        rep = "📥 Téléchargeur MP3 Intelligent ouvert sur l'écran du PC !"
        synchroniser_ecran_pc(ordre, rep)
        return rep

    if re.search(r"\b(quelle heure|l'heure|heure est-il|donne l'heure)\b", low) or low == "heure":
        now = datetime.datetime.now()
        rep = f"🕒 Il est {now.strftime('%H:%M')} (le {now.strftime('%d/%m/%Y')})."
        synchroniser_ecran_pc(ordre, rep)
        return rep

    # 2. Exécution des boutons explicites (BTN:...) avec affichage graphique sur PC
    if is_btn:
        outils = map_outils()
        for nom_btn in sorted(outils.keys(), key=len, reverse=True):
            if low == nom_btn or low.startswith(nom_btn + " "):
                sc = outils[nom_btn]
                arg = ordre[len(nom_btn):].strip()
                out = run_action(["bash", sc] + ([arg] if arg else []), env_pc, timeout=8)
                rep = out[-2500:] if out else f"✅ {nom_btn.capitalize()} lancé sur l'écran du PC !"
                synchroniser_ecran_pc(ordre, rep)
                return rep

    # 3. Routage universel (Réflexes, Interpréteur, Cerveau IA) avec GUI PC actif
    out = run_action(["bash", f"{ROOT}/tiffany_actions.sh", ordre], env_pc, timeout=45)
    rep = out[-2500:] if out else f"✅ Action « {ordre} » déclenchée sur le PC."
    synchroniser_ecran_pc(ordre, rep)
    return rep
