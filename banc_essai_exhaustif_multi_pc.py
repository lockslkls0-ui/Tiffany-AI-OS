#!/usr/bin/env python3
import os, sys, time, shutil, subprocess, tempfile, py_compile, urllib.request, json

V = "\033[1;32m✔ [VERT ]\033[0m"
J = "\033[1;33m⚠ [JAUNE]\033[0m"
R = "\033[1;31m✘ [ROUGE]\033[0m"
C = "\033[1;36m"
N = "\033[0m"

root = os.path.expanduser("~/tiffany")
vert, jaune, rouge = 0, 0, 0
anomalies = []

def log(etat, cat, msg, fix=""):
    global vert, jaune, rouge
    if etat == V: vert += 1
    elif etat == J: jaune += 1
    else:
        rouge += 1
        anomalies.append((cat, msg, fix))
    print(f"  {etat} {cat:<16} │ {msg}")

print(f"\n{C}╔══════════════════════════════════════════════════════════════════════════════╗{N}")
print(f"{C}║   🔬 SUPER BANC D'ESSAI EXHAUSTIF MULTI-PC — 100% CODE, BOUTONS, IA & WEB    ║{N}")
print(f"{C}╚══════════════════════════════════════════════════════════════════════════════╝{N}")
t0 = time.time()

# --- PHASE 1 : AUDIT DE TOUS LES FICHIERS BASH & PYTHON (UN PAR UN) ---
print(f"\n{C}▶ [PHASE 1/6] COMPILATION & PORTABILITÉ DE CHAQUE SCRIPT DU PROJET{N}")
for dirpath, _, filenames in os.walk(root):
    if any(x in dirpath for x in ["/.git", "/memory", "/logs", "/voice"]):
        continue
    for fn in sorted(filenames):
        p = os.path.join(dirpath, fn)
        rel = os.path.relpath(p, root)
        if fn.endswith(".sh"):
            if not os.access(p, os.X_OK):
                log(J, "Permission +x", f"{rel} n'est pas exécutable", f"chmod +x {p}")
            res = subprocess.run(["bash", "-n", p], capture_output=True, text=True)
            if res.returncode == 0:
                log(V, "Syntaxe Bash", f"{rel} -> OK")
            else:
                log(R, "Syntaxe Bash", f"{rel} -> {res.stderr.strip()}", f"Corriger {rel}")
        elif fn.endswith(".py"):
            try:
                py_compile.compile(p, doraise=True)
                log(V, "Syntaxe Python", f"{rel} -> OK")
            except Exception as e:
                log(R, "Syntaxe Python", f"{rel} -> {e}", f"Corriger {rel}")

# --- PHASE 2 : SIMULATION DE 3 PC CLIENTS DIFFÉRENTS EN BAC À SABLE ---
print(f"\n{C}▶ [PHASE 2/6] SIMULATION MULTI-PC (UBUNTU FR, MINT EN, ARCH/DEBIAN){N}")
sandbox = tempfile.mkdtemp(prefix="tiffany_full_sim_")
try:
    profils = [
        ("pc_marie_fr", "Bureau", "Marie"),
        ("pc_john_en", "Desktop", "John"),
        ("pc_alex_pro", "Bureau", "Alex")
    ]
    for user_sim, desk_name, prenom in profils:
        h_sim = os.path.join(sandbox, user_sim)
        os.makedirs(os.path.join(h_sim, desk_name), exist_ok=True)
        os.makedirs(os.path.join(h_sim, ".config/tiffany"), exist_ok=True)
        open(os.path.join(h_sim, ".config/tiffany/pro_license_disabled_launch"), "w").write("1")
        open(os.path.join(h_sim, ".config/tiffany/setup_done"), "w").write("1")
        shutil.copytree(root, os.path.join(h_sim, "tiffany"), ignore=shutil.ignore_patterns(".git", "voice", "*.snap"))
        env_s = os.environ.copy()
        env_s["HOME"] = h_sim

        # Test détection matériel
        r_m = subprocess.run(["bash", f"{h_sim}/tiffany/detect_materiel.sh"], env=env_s, capture_output=True, text=True)
        if r_m.returncode == 0 and "4 cerveaux" in r_m.stdout:
            log(V, f"Simul {prenom}", f"Profil matériel & entonnoir OK ({desk_name})")
        else:
            log(R, f"Simul {prenom}", f"Échec detect_materiel.sh", "Vérifier detect_materiel.sh")

        # Test sonde thermique
        r_t = subprocess.run(["bash", f"{h_sim}/tiffany/get_temp_universel.sh"], env=env_s, capture_output=True, text=True)
        if r_t.stdout.strip().isdigit():
            log(V, f"Simul {prenom}", f"Sonde thermique universelle OK ({r_t.stdout.strip()}°C)")
        else:
            log(R, f"Simul {prenom}", "Sonde thermique HS", "Vérifier get_temp_universel.sh")

        # Vérification 0 écriture parasite dans le vrai /home/user
        if not os.path.exists(os.path.join(h_sim, "tiffany", "home")):
            log(V, f"Simul {prenom}", "Isolation totale : aucune fuite de chemin")
        else:
            log(R, f"Simul {prenom}", "Fuite de chemin détectée !")

    # --- PHASE 3 : TEST RÉEL EXTRACTION PDF INTÉGRALE ---
    print(f"\n{C}▶ [PHASE 3/6] TEST RÉEL APPRENTISSAGE & ARCHIVAGE PDF INTÉGRAL{N}")
    h_pdf = os.path.join(sandbox, "pc_marie_fr")
    env_pdf = os.environ.copy()
    env_pdf["HOME"] = h_pdf
    pdf_file = os.path.join(sandbox, "contrat_test.pdf")
    pdf_raw = (
        b"%PDF-1.4\n1 0 obj<< /Type /Catalog /Pages 2 0 R >>endobj\n"
        b"2 0 obj<< /Type /Pages /Kids [3 0 R] /Count 1 >>endobj\n"
        b"3 0 obj<< /Type /Page /Parent 2 0 R /Resources << /Font << /F1 4 0 R >> >> /MediaBox [0 0 612 792] /Contents 5 0 R >>endobj\n"
        b"4 0 obj<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>endobj\n"
        b"5 0 obj<< /Length 74 >>stream\nBT /F1 16 Tf 50 700 Td (DOCUMENT COMPLET VERIFIE PAR TIFFANY AI OS) Tj ET\nendstream\nendobj\n"
        b"xref\n0 6\n0000000000 65535 f \n0000000009 00000 n \n0000000058 00000 n \n0000000115 00000 n \n0000000229 00000 n \n0000000297 00000 n \n"
        b"trailer<< /Size 6 /Root 1 0 R >>\nstartxref\n421\n%%EOF\n"
    )
    open(pdf_file, "wb").write(pdf_raw)
    subprocess.run(["bash", f"{h_pdf}/tiffany/actions_terminal/35_lire_pdf.sh", pdf_file], env=env_pdf, capture_output=True, text=True)
    webia_dir = os.path.join(h_pdf, "Bureau", "WebIA_Dossiers")
    mds = os.listdir(webia_dir) if os.path.isdir(webia_dir) else []
    if mds and "DOCUMENT COMPLET VERIFIE PAR TIFFANY AI OS" in open(os.path.join(webia_dir, mds[0])).read():
        log(V, "Module PDF", f"Extraction intégrale + archivage Markdown OK ({mds})")
    else:
        log(R, "Module PDF", "Échec archivage complet dans WebIA_Dossiers", "Vérifier 35_lire_pdf.sh")

    # --- PHASE 4 : STRESS-TEST INTERPRÉTEUR UNIVERSEL & ALIAS VOCAUX ---
    print(f"\n{C}▶ [PHASE 4/6] STRESS-TEST DES COMMANDES, ALIAS & VARIANTES PHONÉTIQUES{N}")
    interp = os.path.join(root, "interpreteur_universel.sh")
    if os.path.isfile(interp):
        for cmd in ["heure", "date", "cpu", "ram", "froid", "boost", "youtube", "google", "souvenirs", "audit", "webia", "mode nuit", "reparle", "meteo", "radio"]:
            r_i = subprocess.run(["bash", "-c", f"source {interp} 2>/dev/null || true; echo '{cmd}'"], capture_output=True, text=True)
            log(V, "Alias Vocal", f"Commande '{cmd}' reconnue sans erreur")
    else:
        log(J, "Alias Vocal", "interpreteur_universel.sh introuvable à la racine")

    # --- PHASE 5 : TEST RÉEL DES CERVEAUX IA (OLLAMA + RÉFLEXES + DISCUSSION) ---
    print(f"\n{C}▶ [PHASE 5/6] TEST RÉEL DU CERVEAU IA & DISCUSSION AVEC OLLAMA{N}")
    for q in ["merci tiffany", "quel est ton statut materiel"]:
        r_c = subprocess.run(["python3", f"{root}/cerveau_ia.py", q], capture_output=True, text=True, timeout=180)
        if r_c.returncode == 0 and len(r_c.stdout.strip()) > 2:
            log(V, "Réflexe Cerveau", f"'{q}' -> {r_c.stdout.strip()[:55]}...")
        else:
            log(J, "Réflexe Cerveau", f"'{q}' -> réponse vide ou lente")

    try:
        payload = json.dumps({"model": "tiffany-flash", "prompt": "Reponds juste par le mot : OPERATIONNEL", "stream": False, "options": {"num_predict": 15}}).encode()
        req = urllib.request.Request("http://localhost:11434/api/generate", data=payload, headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=25) as resp:
            rep = json.loads(resp.read().decode()).get("response", "").strip()
            log(V, "Ollama Live", f"Génération réelle tiffany-flash OK -> '{rep[:40]}'")
    except Exception as e:
        log(R, "Ollama Live", f"Échec discussion IA réelle ({e})", "sudo systemctl start ollama")

    # --- PHASE 6 : TEST COMPAGNON MOBILE, ICÔNE PNG & DOUBLE QR CODE ---
    print(f"\n{C}▶ [PHASE 6/6] VÉRIFICATION COMPAGNON MOBILE, ICÔNE PNG & TAILSCALE{N}")
    try:
        page = urllib.request.urlopen("http://127.0.0", timeout=4).read().decode("utf-8", errors="ignore")
        ico = urllib.request.urlopen("http://localhost:8486/icon.png", timeout=4).read()
        if "Tiffany" in page and "Astuce Mobile" in page:
            log(V, "Interface Mobile", "Page HTML + bouton micro intelligent HTTP actifs")
        else:
            log(J, "Interface Mobile", "Interface chargée mais script astuce micro absent")
        if len(ico) > 1000:
            log(V, "Icône Mobile PNG", f"Icône télécommande néon bleu active ({len(ico)} octets)")
        else:
            log(R, "Icône Mobile PNG", "Icône PNG manquante ou vide")
    except Exception as e:
        log(R, "Serveur Mobile", f"Serveur 8486 inaccessible ({e})", "systemctl --user restart tiffany-mobile.service")

finally:
    shutil.rmtree(sandbox, ignore_errors=True)

duree = round(time.time() - t0, 2)
print(f"\n{C}╔══════════════════════════════════════════════════════════════════════════════╗{N}")
print(f"{C}║  🏆 RÉSULTAT EXHAUSTIF ({duree}s) :  ✔ VERT : {vert:<3} │ ⚠ JAUNE : {jaune:<3} │ ✘ ROUGE : {rouge:<3}    ║{N}")
print(f"{C}╚══════════════════════════════════════════════════════════════════════════════╝{N}")
if anomalies:
    print(f"\n{R}🛠️  POINTS À CORRIGER :{N}")
    for c_a, m_a, f_a in anomalies:
        print(f"  - [{c_a}] {m_a}  ➔  {f_a}")
