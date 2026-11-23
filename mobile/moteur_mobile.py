import os, re, json, glob, hashlib, secrets, subprocess

ROOT = os.path.expanduser("~/tiffany")
BIN_MOB = os.path.expanduser("~/tiffany/mobile/bin")
PIN_FILE = os.path.expanduser("~/.config/tiffany/mobile_pin.hash")
RAW_FILE = os.path.expanduser("~/.config/tiffany/mobile_pin.txt")

def _h(pin):
    return hashlib.sha256(("tiffany_salt_" + pin.strip()).encode()).hexdigest()

def init_pin():
    if not os.path.exists(PIN_FILE):
        pin = open(RAW_FILE).read().strip() if os.path.exists(RAW_FILE) else str(secrets.randbelow(9000) + 1000)
        open(PIN_FILE, "w").write(_h(pin))
        open(RAW_FILE, "w").write(pin)
        os.chmod(RAW_FILE, 0o600)
    return open(RAW_FILE).read().strip() if os.path.exists(RAW_FILE) else "****"

def check_pin(pin):
    return os.path.exists(PIN_FILE) and _h(pin) == open(PIN_FILE).read().strip()

def set_pin(npin):
    npin = npin.strip()
    if len(npin) < 4 or not npin.isdigit():
        return "❌ Le PIN doit contenir au moins 4 chiffres."
    open(PIN_FILE, "w").write(_h(npin))
    open(RAW_FILE, "w").write(npin)
    os.chmod(RAW_FILE, 0o600)
    return "✅ Nouveau code PIN sécurisé (SHA-256) enregistré !"

def stats():
    try:
        ts = [int(open(z).read())/1000.0 for z in glob.glob("/sys/class/thermal/thermal_zone*/temp") if 10000 < int(open(z).read()) < 120000]
        temp = f"{max(ts):.1f}°C" if ts else "N/A"
    except Exception: temp = "N/A"
    try:
        m = subprocess.check_output(["free", "-m"]).decode().splitlines().pop(1).split()
        tot, used = int(m.pop(1)), int(m.pop(1))
        ram = f"{used*100//tot}% ({used}/{tot} Mo)"
    except Exception: ram = "N/A"
    prompt = None
    if os.path.exists("/tmp/tiffany_mob_prompt.json"):
        try: prompt = json.loads(open("/tmp/tiffany_mob_prompt.json", encoding="utf-8").read())
        except Exception: pass
    return {"temp": temp, "ram": ram, "prompt": prompt}

def map_outils():
    mapping = {}
    for d in ("plugins", "actions_terminal"):
        for f in sorted(glob.glob(os.path.join(ROOT, d, "*.sh"))):
            b = os.path.basename(f)
            if b.endswith(".off"): continue
            nom = re.sub(r"^\d+[a-z]?_|^Z\d+_", "", b[:-3]).replace("_", " ").strip().lower()
            if not nom:
                nom = b[:-3].replace("_", " ").strip().lower()
            if nom and nom not in mapping:
                mapping[nom] = f
    return mapping

def lister_outils():
    return [(k.capitalize(), k) for k in map_outils().keys()]

def clean(s):
    return re.sub(r'\x1b\[[0-9;]*[a-zA-Z]', '', s).strip()

def executer(ordre):
    ordre = ordre.strip()
    if not ordre: return "Ordre vide."
    for tmp in ("/tmp/tiffany_mob_info.txt", "/tmp/tiffany_mob_prompt.json"):
        try: os.remove(tmp)
        except Exception: pass

    env = os.environ.copy()
    env["DISPLAY"] = ":0"
    env["TIFFANY_MOBILE"] = "1"
    env["PATH"] = f"{BIN_MOB}:{env.get('PATH', '')}"

    low = ordre.lower()
    if "audit mobile" in low:
        return clean(subprocess.check_output(["python3", f"{ROOT}/mobile/audit_mobile_integral.py"], stderr=subprocess.STDOUT, timeout=60).decode("utf-8", "ignore"))[-1800:]
    if any(k in low for k in ("banc", "audit total", "143")):
        return clean(subprocess.check_output(["python3", f"{ROOT}/audit_total_ultime.py"], stderr=subprocess.STDOUT, timeout=45).decode("utf-8", "ignore"))[-1500:]
    if any(k in low for k in ("simulation", "test audio")):
        return clean(subprocess.check_output(["python3", f"{ROOT}/simulation_totale_audio.py"], stderr=subprocess.STDOUT, timeout=60).decode("utf-8", "ignore"))[-1500:]
    if low in ("analyse", "bilan"):
        st = stats(); up = subprocess.check_output(["uptime", "-p"]).decode().strip()
        return f"📊 ANALYSE EN DIRECT :\n• CPU : {st['temp']}\n• RAM : {st['ram']}\n• Uptime : {up}"

    # 1. Execution directe si l'ordre correspond exactement a un bouton/plugin (avec argument optionnel)
    outils = map_outils()
    script_cible = None
    arg_extra = ""
    for nom_btn in sorted(outils.keys(), key=len, reverse=True):
        if low == nom_btn or low.startswith(nom_btn + " "):
            script_cible = outils[nom_btn]
            arg_extra = ordre[len(nom_btn):].strip()
            break

    if script_cible:
        cmd_run = ["bash", script_cible] + ([arg_extra] if arg_extra else [])
        # Fournit une entree vide sur stdin pour eviter le blocage 'read' terminal
        res = clean(subprocess.check_output(cmd_run, input=b"\n", env=env, stderr=subprocess.STDOUT, timeout=90).decode("utf-8", "ignore"))
        info_extra = clean(open("/tmp/tiffany_mob_info.txt", encoding="utf-8").read()) if os.path.exists("/tmp/tiffany_mob_info.txt") else ""
        comb = (res + "\n" + info_extra).strip()
        return comb[-1500:] if comb else f"✅ {os.path.basename(script_cible)} exécuté."

    # 2. Sinon correction phonetique + interpreteur universel
    corr = f"{ROOT}/correcteur_phonetique.sh"
    if os.path.exists(corr):
        try:
            c = subprocess.check_output(["bash", corr, ordre], env=env, stderr=subprocess.DEVNULL, timeout=5).decode("utf-8", "ignore").strip()
            if c: ordre = c
        except Exception: pass

    interp = f"{ROOT}/interpreteur_universel.sh"
    if os.path.exists(interp):
        try:
            res = clean(subprocess.check_output(["bash", interp, ordre], input=b"\n", env=env, stderr=subprocess.STDOUT, timeout=60).decode("utf-8", "ignore"))
            info_extra = clean(open("/tmp/tiffany_mob_info.txt", encoding="utf-8").read()) if os.path.exists("/tmp/tiffany_mob_info.txt") else ""
            comb = (res + "\n" + info_extra).strip()
            if comb and "inconnu" not in comb.lower(): return comb[-1500:]
        except Exception: pass

    # 3. Sinon Cerveau IA local (Ollama)
    try:
        pay = json.dumps({"model": "tiffany-flash", "prompt": f"Réponds brièvement en français en tant que Tiffany AI-OS : {ordre}", "stream": False}).encode()
        raw = subprocess.check_output(["curl", "-s", "-m", "30", "http://127.0.0", "-d", pay]).decode("utf-8", "ignore")
        rep = json.loads(raw).get("response", "").strip()
        if rep: return rep
    except Exception: pass
    return f"✅ Ordre exécuté : {ordre}"
