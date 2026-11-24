import os, re, json, glob, time, shutil, hashlib, subprocess, datetime

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
        ram = f"{int(m)*100//int(m)}%"
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
    s = re.sub(r'\x1b\[[0-9;]*[a-zA-Z]', '', s)
    return "\n".join(l.rstrip() for l in s.splitlines() if l.strip()).strip()

def get_env():
    uid = os.getuid()
    home = os.path.expanduser("~")
    env = os.environ.copy()
    env["DISPLAY"] = ":0"
    env["XAUTHORITY"] = os.path.join(home, ".Xauthority")
    env["XDG_RUNTIME_DIR"] = f"/run/user/{uid}"
    env["DBUS_SESSION_BUS_ADDRESS"] = f"unix:path=/run/user/{uid}/bus"
    env["TIFFANY_MOBILE"] = "1"
    env["PATH"] = f"{ROOT}/mobile/bin:{ROOT}/bin:{home}/.local/bin:/usr/local/bin:/usr/bin:/bin:" + env.get("PATH", "")
    return env

def journaliser_et_afficher_pc(ordre, reponse):
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
        for _ in range(35):
            time.sleep(0.1)
            if os.path.exists("/tmp/tiffany_core_ready") and os.path.exists(fifo):
                break
    if os.path.exists(fifo):
        try:
            fd = os.open(fifo, os.O_WRONLY | os.O_NONBLOCK)
            msg_pc = f"[📱 Mobile] {ordre}\n🌹 Tiffany (Mobile) : {reponse[:300]}\n"
            os.write(fd, msg_pc.encode("utf-8"))
            os.close(fd)
        except Exception:
            pass

def executer(ordre):
    ordre_brut = ordre.strip()
    if not ordre_brut: return "Ordre vide."
    env = get_env()
    is_btn = ordre_brut.startswith("BTN:")
    ordre = ordre_brut[4:].strip() if is_btn else ordre_brut
    low = ordre.lower()

    # 1. Raccourcis matériels directs (Boost / Froid garantis sans blocage)
    if re.search(r"\b(boost|mode boost|pleine puissance|accelere)\b", low):
        subprocess.run(["bash", f"{ROOT}/plugins/12_mode_boost.sh"], env=env, timeout=10)
        gov = open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor").read().strip() if os.path.exists("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor") else "ondemand"
        rep = f"⚡ Mode Boost activé ! (Gouverneur CPU : {gov} | Auto-régulation thermique active)."
        journaliser_et_afficher_pc(ordre, rep)
        return rep

    if re.search(r"\b(froid|mode froid|refroidis|ca chauffe|trop chaud)\b", low):
        subprocess.run(["bash", f"{ROOT}/plugins/11_mode_froid.sh"], env=env, timeout=10)
        gov = open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor").read().strip() if os.path.exists("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor") else "powersave"
        rep = f"❄️ Mode Froid activé ! (Gouverneur CPU : {gov} | Refroidissement en cours)."
        journaliser_et_afficher_pc(ordre, rep)
        return rep

    # 2. Heure & Météo instantanées
    if re.search(r"\b(quelle heure|l'heure|heure est-il|donne l'heure)\b", low) or low == "heure":
        now = datetime.datetime.now()
        rep = f"🕒 Il est {now.strftime('%H:%M')} (nous sommes le {now.strftime('%d/%m/%Y')})."
        journaliser_et_afficher_pc(ordre, rep)
        return rep

    if re.search(r"\b(meteo|météo|quel temps)\b", low):
        ville = re.sub(r".*\b(meteo|météo|quel temps)\b\s*(fait-il|a|à|de|du|pour)?\s*", "", low).strip()
        try:
            m_txt = subprocess.check_output(["curl", "-s", "-m", "8", f"https://wttr.in{ville}?format=%l:+%c+%t+(ressenti+%f),+%w&lang=fr"]).decode("utf-8", "ignore").strip()
            if m_txt and "Unknown" not in m_txt and "<html" not in m_txt.lower():
                rep = f"🌤️ Météo : {m_txt}"
                journaliser_et_afficher_pc(ordre, rep)
                return rep
        except Exception:
            pass

    # 3. Exécution directe d'un bouton cliqué (renvoie tout le texte de sortie sur le téléphone)
    if is_btn:
        outils = map_outils()
        for nom_btn in sorted(outils.keys(), key=len, reverse=True):
            if low == nom_btn or low.startswith(nom_btn + " "):
                sc = outils[nom_btn]
                arg = ordre[len(nom_btn):].strip()
                cmd = ["bash", sc] + ([arg] if arg else [])
                try:
                    out = clean(subprocess.check_output(cmd, input=b"\n", env=env, stderr=subprocess.STDOUT, timeout=45).decode("utf-8", "ignore"))
                    rep = out[-2500:] if out else f"✅ {nom_btn.capitalize()} terminé."
                except subprocess.TimeoutExpired:
                    rep = f"⏳ {nom_btn.capitalize()} ouvert (en attente d'action)."
                except Exception as e:
                    rep = f"⚠️ {nom_btn.capitalize()} : {e}"
                journaliser_et_afficher_pc(ordre, rep)
                return rep

    # 4. Phrase libre / Conversation / Action vocale (passe par tiffany_actions.sh -> réflexes + outils + IA)
    try:
        out = clean(subprocess.check_output(["bash", f"{ROOT}/tiffany_actions.sh", ordre], input=b"\n", env=env, stderr=subprocess.STDOUT, timeout=45).decode("utf-8", "ignore"))
        if out:
            rep = out[-2500:]
            journaliser_et_afficher_pc(ordre, rep)
            return rep
    except subprocess.TimeoutExpired:
        rep = f"⏳ Action '{ordre}' en cours sur le PC."
        journaliser_et_afficher_pc(ordre, rep)
        return rep
    except Exception:
        pass

    rep = f"✅ Ordre transmis à Tiffany : {ordre}"
    journaliser_et_afficher_pc(ordre, rep)
    return rep
