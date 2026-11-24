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
    mirror_f = "/tmp/tiffany_live_mirror.log"
    os.makedirs(os.path.dirname(log_f), exist_ok=True)
    horo = datetime.datetime.now().strftime("%H:%M:%S")
    horo_full = datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    with open(log_f, "a", encoding="utf-8") as f:
        f.write(f"[{horo_full}] USER (Mobile): {ordre}\n")
        if reponse:
            f.write(f"[{horo_full}] TIFFANY (Mobile): {reponse}\n")
    with open(mirror_f, "a", encoding="utf-8") as mf:
        mf.write(f"
[{horo}] 📱 VOUS : {ordre}
[{horo}] 🌹 TIFFANY :
{reponse}\n" + "─"*50 + "
")
    env = get_env()
    wins = subprocess.getoutput("DISPLAY=:0 wmctrl -l 2>/dev/null")
    if "Suivi_Mobile_Tiffany" not in wins:
        subprocess.Popen([
            "systemd-run", "--user", "--quiet",
            "--setenv=DISPLAY=:0",
            f"--setenv=DBUS_SESSION_BUS_ADDRESS={env['DBUS_SESSION_BUS_ADDRESS']}",
            f"--setenv=XAUTHORITY={env['XAUTHORITY']}",
            "gnome-terminal", "--title=Suivi_Mobile_Tiffany", "--",
            "bash", "-c", "clear; echo '🌹 SUIVI EN DIRECT — TÉLÉPHONE ↔ TIFFANY'; echo '=================================================='; tail -n 30 -f /tmp/tiffany_live_mirror.log"
        ])


def run_script_fast(cmd_list, env, timeout=15):
    # Exécute un script sans rester bloqué par les processus audio (espeak-ng) en arrière-plan
    p = subprocess.Popen(cmd_list, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env, start_new_session=True)
    try:
        out, _ = p.communicate(timeout=timeout)
        return clean(out.decode("utf-8", errors="ignore"))
    except subprocess.TimeoutExpired:
        return None

def executer(ordre):
    ordre_brut = ordre.strip()
    if not ordre_brut: return "Ordre vide."
    env = get_env()
    is_btn = ordre_brut.startswith("BTN:")
    ordre = ordre_brut[4:].strip() if is_btn else ordre_brut
    low = ordre.lower()

    if re.search(r"(boost|mode boost|pleine puissance|accelere)", low):
        open("/tmp/tiffany_cpu_mode", "w").write("auto
")
        subprocess.run(["bash", "-c", "echo 100 | sudo -n tee /sys/devices/system/cpu/intel_pstate/max_perf_pct >/dev/null 2>&1; for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance | sudo -n tee $g >/dev/null 2>&1 || echo ondemand | sudo -n tee $g >/dev/null 2>&1; done"], env=env)
        mhz = subprocess.getoutput("awk -F': ' '/cpu MHz/{print int($2); exit}' /proc/cpuinfo")
        rep = f"⚡ Mode Boost activé ! (Puissance CPU : 100% | Cadence actuelle : {mhz} MHz)."
        journaliser_et_afficher_pc(ordre, rep)
        return rep

    if re.search(r"(froid|mode froid|refroidis|ca chauffe|trop chaud)", low):
        open("/tmp/tiffany_cpu_mode", "w").write("force_froid
")
        subprocess.run(["bash", "-c", "echo 45 | sudo -n tee /sys/devices/system/cpu/intel_pstate/max_perf_pct >/dev/null 2>&1; for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo powersave | sudo -n tee $g >/dev/null 2>&1; done"], env=env)
        mhz = subprocess.getoutput("awk -F': ' '/cpu MHz/{print int($2); exit}' /proc/cpuinfo")
        rep = f"❄️ Mode Froid activé ! (Plafond CPU : 45% | Cadence actuelle : {mhz} MHz)."
        journaliser_et_afficher_pc(ordre, rep)
        return rep

    # 2. Téléchargeur MP3 Pro (lancement détaché pour que la fenêtre askBox s'affiche immédiatement sur le téléphone)
    if "telechargeur mp3 pro" in low:
        subprocess.Popen(["bash", os.path.expanduser("~/.local/bin/telechargeur_mp3_pro.sh")], env=env, start_new_session=True)
        rep = "🎧 Téléchargeur MP3 Pro ouvert dans le cadre interactif ci-dessus !"
        journaliser_et_afficher_pc(ordre, rep)
        return rep

    # 3. Heure & Météo instantanées (0.1s)
    if re.search(r"\b(quelle heure|l'heure|heure est-il|donne l'heure)\b", low) or low == "heure":
        now = datetime.datetime.now()
        rep = f"🕒 Il est {now.strftime('%H:%M')} (le {now.strftime('%d/%m/%Y')})."
        journaliser_et_afficher_pc(ordre, rep)
        return rep

    if re.search(r"\b(meteo|météo|quel temps)\b", low):
        ville = re.sub(r".*\b(meteo|météo|quel temps)\b\s*(fait-il|a|à|de|du|pour)?\s*", "", low).strip()
        try:
            m_txt = subprocess.check_output(["curl", "-s", "-m", "6", f"https://wttr.in{ville}?format=%l:+%c+%t+(ressenti+%f),+%w&lang=fr"]).decode("utf-8", "ignore").strip()
            if m_txt and "Unknown" not in m_txt and "<html" not in m_txt.lower():
                rep = f"🌤️ Météo : {m_txt}"
                journaliser_et_afficher_pc(ordre, rep)
                return rep
        except Exception:
            pass

    # 4. Boutons directs (renvoie immédiatement tout le texte écrit sur le téléphone)
    if is_btn:
        outils = map_outils()
        for nom_btn in sorted(outils.keys(), key=len, reverse=True):
            if low == nom_btn or low.startswith(nom_btn + " "):
                sc = outils[nom_btn]
                arg = ordre[len(nom_btn):].strip()
                out = run_script_fast(["bash", sc] + ([arg] if arg else []), env, timeout=15)
                rep = out[-2500:] if out else f"🔔 {nom_btn.capitalize()} ouvert (voir cadre interactif ci-dessus)."
                journaliser_et_afficher_pc(ordre, rep)
                return rep

    # 5. Conversation & Commandes naturelles (réponse instantanée sans attendre espeak-ng)
    out = run_script_fast(["bash", f"{ROOT}/tiffany_actions.sh", ordre], env, timeout=20)
    rep = out[-2500:] if out else f"✅ Ordre exécuté : {ordre}"
    journaliser_et_afficher_pc(ordre, rep)
    return rep
