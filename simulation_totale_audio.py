#!/usr/bin/env python3
import os, time, json, wave, subprocess, urllib.request, importlib.util

ROOT = os.path.expanduser("~/tiffany")
V, R, J, B, C, G, Z = "\033[92m", "\033[91m", "\033[93m", "\033[96m", "\033[95m", "\033[90m", "\033[0m"
ok, err = 0, 0

def log_res(cond, titre, info=""):
    global ok, err
    if cond:
        ok += 1
        print(f"  {V}✔ [OK   ]{Z} {titre:<48} {G}{info}{Z}")
    else:
        err += 1
        print(f"  {R}✘ [ÉCHEC]{Z} {titre:<48} {R}{info}{Z}")

print(f"\n{B}╔════════════════════════════════════════════════════════════════════════════╗")
print(f"║     🎬 SIMULATION INTÉGRALE AUDIO & SYSTÈME EN DIRECT — TIFFANY V48.6      ║")
print(f"╚════════════════════════════════════════════════════════════════════════════╝{Z}\n")

# --- 1. TEST AUDIO RÉEL DES DEUX VOIX ---
print(f"{C}▶ [1/5] TEST AUDIO RÉEL (VOIX LÉGÈRE & VOIX DOUCE SIWIS HD){Z}")
mode_file = os.path.join(ROOT, "voice/mode_voix.txt")
ancien_mode = open(mode_file).read().strip() if os.path.exists(mode_file) else "piper"

# S'assurer que le son système n'est pas muet
subprocess.run(["pactl", "set-sink-mute", "@DEFAULT_SINK@", "0"], stderr=subprocess.DEVNULL)

# Test Voix Légère
open(mode_file, "w").write("espeak\n")
t0 = time.time()
r1 = subprocess.run([os.path.join(ROOT, "bin/espeak-ng"), "Test un : voix légère et vive."], stderr=subprocess.DEVNULL)
log_res(r1.returncode == 0, "Sortie Audio : Voix Légère (eSpeak)", f"({round(time.time()-t0, 2)}s)")

# Test Voix Douce Siwis HD
open(mode_file, "w").write("piper\n")
t0 = time.time()
r2 = subprocess.run([os.path.join(ROOT, "bin/espeak-ng"), "Test deux : ma voix douce Siwis haute définition."], stderr=subprocess.DEVNULL)
log_res(r2.returncode == 0, "Sortie Audio : Voix Douce Siwis HD (Piper 16kHz)", f"({round(time.time()-t0, 2)}s)")

# Restauration du profil d'origine
open(mode_file, "w").write(ancien_mode + "\n")

# --- 2. TEST CAPTURE MICRO RÉELLE + DÉCODEUR VOSK FR ---
print(f"\n{C}▶ [2/5] TEST MICROPHONE PHYSIQUE & RECONNAISSANCE VOSK FR{Z}")
wav_tmp = "/tmp/sim_tiffany_mic.wav"
subprocess.run(["pactl", "set-source-mute", "@DEFAULT_SOURCE@", "0"], stderr=subprocess.DEVNULL)
r_mic = subprocess.run(["arecord", "-d", "1", "-f", "S16_LE", "-r", "16000", "-c", "1", "-q", wav_tmp], stderr=subprocess.DEVNULL)
mic_ok = r_mic.returncode == 0 and os.path.exists(wav_tmp) and os.path.getsize(wav_tmp) > 1000
log_res(mic_ok, "Capture audio microphone physique (16kHz mono)", f"({os.path.getsize(wav_tmp) if os.path.exists(wav_tmp) else 0} octets)")

vosk_ok = False
if mic_ok:
    try:
        from vosk import Model, KaldiRecognizer, SetLogLevel
        SetLogLevel(-1)
        wf = wave.open(wav_tmp, "rb")
        mod = Model(os.path.join(ROOT, "voice/vosk-fr/vosk-model-small-fr-0.22"))
        rec = KaldiRecognizer(mod, wf.getframerate())
        rec.AcceptWaveform(wf.readframes(wf.getnframes()))
        _ = json.loads(rec.FinalResult())
        vosk_ok = True
    except Exception:
        vosk_ok = False
    os.remove(wav_tmp)
log_res(vosk_ok, "Décodage neuronal Vosk FR sur flux micro réel", "Opérationnel")

# --- 3. TEST CHAÎNE DE COMMANDES & CAPTEURS ---
print(f"\n{C}▶ [3/5] TEST EXÉCUTION RÉELLE DES RÉFLEXES & CAPTEURS{Z}")
for cmd_test, label in [
    ("heure", "Horloge vocale & affichage"),
    ("est-ce que je suis branché", "Capteur batterie & secteur"),
    ("ca chauffe", "Capteur température CPU"),
    ("comment va la ram", "Capteur mémoire vive RAM"),
]:
    out = subprocess.getoutput(f"bash '{ROOT}/tiffany_actions.sh' '{cmd_test}' 2>/dev/null")
    log_res("Tiffany :" in out, f"Exécution réelle : '{cmd_test}' ({label})", "Réponse générée")

# --- 4. TEST EN DIRECT DES 2 CERVEAUX IA OLLAMA ---
print(f"\n{C}▶ [4/5] TEST RÉEL DES 2 CERVEAUX IA LOCAUX (OLLAMA){Z}")
for modele, nom_c, prompt in [
    ("tiffany-flash", "Petit Cerveau Rapide (tiffany-flash)", "Réponds en 5 mots : es-tu prête ?"),
    ("qwen2.5:1.5b", "Gros Cerveau Analytique (qwen2.5:1.5b)", "Réponds en 5 mots : test réussi.")
]:
    t0 = time.time()
    res_ia = subprocess.run(["nice", "-n", "19", "ollama", "run", modele, prompt], capture_output=True, text=True, timeout=60)
    rep = " ".join(res_ia.stdout.split())
    ia_ok = (res_ia.returncode == 0 and len(rep) > 0)
    log_res(ia_ok, nom_c, f"({round(time.time()-t0, 1)}s) ➔ '{rep[:35]}'")

# --- 5. TEST CYCLE COMPLET MÉMOIRE ---
print(f"\n{C}▶ [5/5] TEST ÉCRITURE & LECTURE MÉMOIRE EN DIRECT{Z}")
raw_log = os.path.join(ROOT, "logs/session_raw.txt")
facts_f = os.path.join(ROOT, "memory/long_term_facts.json")
avant_raw = open(raw_log, encoding="utf-8", errors="ignore").read() if os.path.exists(raw_log) else ""
avant_facts = open(facts_f, encoding="utf-8", errors="ignore").read() if os.path.exists(facts_f) else ""

open(raw_log, "a", encoding="utf-8").write("[TEST] USER: Simulation integrale memoire test 999\n")
subprocess.run(["python3", os.path.join(ROOT, "memory_gardener.py")], stderr=subprocess.DEVNULL)
apres_facts = open(facts_f, encoding="utf-8", errors="ignore").read() if os.path.exists(facts_f) else ""
mem_write_ok = "Simulation integrale memoire test 999" in apres_facts

lect = subprocess.getoutput(f"python3 '{ROOT}/lire_memoire_totale.py' 'simulation integrale'")
mem_read_ok = "Simulation integrale memoire test 999" in lect

# Restauration propre des fichiers mémoire pour ne pas laisser de ligne de test
open(raw_log, "w", encoding="utf-8").write(avant_raw)
open(facts_f, "w", encoding="utf-8").write(avant_facts)

log_res(mem_write_ok, "Gravage automatique dans long_term_facts.json", "Vérifié & nettoyé")
log_res(mem_read_ok, "Rappel instantané via lire_memoire_totale.py", "Vérifié & nettoyé")

# --- BILAN FINAL ---
tot = ok + err
score = int(ok * 100 / tot)
print(f"\n{B}╔════════════════════════════════════════════════════════════════════════════╗")
print(f"║  {V}✔ TESTS RÉUSSIS : {ok}/{tot:<3}{B}  |  {R if err else V}✘ ÉCHECS : {err:<3}{B}  |  SCORE GLOBAL : {score}%          ║")
print(f"╚════════════════════════════════════════════════════════════════════════════╝{Z}\n")

if err == 0:
    time.sleep(1.5)
    subprocess.run([os.path.join(ROOT, "bin/espeak-ng"), "Simulation intégrale terminée avec cent pour cent de réussite, mon ange."], stderr=subprocess.DEVNULL)
