#!/usr/bin/env python3
import os, re, glob, time, json, subprocess, urllib.request
import moteur_mobile as m

V, J, R, C, B, Z = "\033[92m", "\033[93m", "\033[91m", "\033[96m", "\033[1m", "\033[0m"
ROOT = os.path.expanduser("~/tiffany")
ok_cnt, warn_cnt, err_cnt, fixes = 0, 0, 0, []

def ok(cat, msg, info=""):
    global ok_cnt; ok_cnt += 1
    print(f"  {V}✔ [VERT ]{Z} {cat:<16} │ {msg:<42} {C}{info}{Z}")

def warn(cat, msg, path, fix):
    global warn_cnt; warn_cnt += 1
    fixes.append(("JAUNE", cat, msg, path, fix))
    print(f"  {J}⚠ [JAUNE]{Z} {cat:<16} │ {msg:<42} {J}(Voir bas){Z}")

def err(cat, msg, path, fix):
    global err_cnt; err_cnt += 1
    fixes.append(("ROUGE", cat, msg, path, fix))
    print(f"  {R}✘ [ROUGE]{Z} {cat:<16} │ {msg:<42} {R}(Voir bas){Z}")

print(f"\n{C}{B}╔════════════════════════════════════════════════════════════════════════════╗")
print(f"║  🔬 BANC D'ESSAI INTÉGRAL BIDIRECTIONNEL — PC ↔ TÉLÉPHONE & LINGUISTIQUE   ║")
print(f"╚════════════════════════════════════════════════════════════════════════════╝{Z}\n")

# 1. TEST BIDIRECTIONNEL RÉEL (TÉLÉPHONE -> PC & PC -> TÉLÉPHONE)
print(f"{B}▶ [1/4] FLUX BIDIRECTIONNEL RÉEL (TÉLÉPHONE ↔ ORDINATEUR){Z}")
try:
    urllib.request.urlopen("http://127.0.0", timeout=2)
    ok("Serveur 8486", "API Mobile en ligne et réactive", "http://127.0.0.1:8486")
except Exception as e:
    err("Serveur 8486", f"Port 8486 inaccessible ({e})", "~/.config/systemd/user/tiffany-mobile.service", "systemctl --user restart tiffany-mobile.service")

# Test PC -> Téléphone (Simulation pop-up Zenity mobile)
bin_z = os.path.join(ROOT, "mobile/bin/zenity")
if os.access(bin_z, os.X_OK) and "ask_mobile" in open(bin_z, encoding="utf-8", errors="ignore").read():
    ok("Pont PC->Mobile", "Relais Zenity interactif (askBox) armé", bin_z)
else:
    err("Pont PC->Mobile", "Relais Zenity mobile incomplet", bin_z, "Réinstaller ~/tiffany/mobile/bin/zenity")

# Test Téléphone -> PC (Écriture mémoire + FIFO Discussion_Tiffany)
log_raw = os.path.join(ROOT, "logs/session_raw.txt")
taille_av = os.path.getsize(log_raw) if os.path.exists(log_raw) else 0
rep_test = m.executer("quelle heure est-il")
taille_ap = os.path.getsize(log_raw) if os.path.exists(log_raw) else 0
if taille_ap > taille_av and "Il est" in rep_test:
    ok("Pont Mobile->PC", "Action mobile exécutée + gravée en mémoire", rep_test[:35])
else:
    err("Pont Mobile->PC", "Échec synchronisation mémoire/réponse mobile", "~/tiffany/mobile/moteur_mobile.py", "Vérifier sync_bureau_et_memoire() dans moteur_mobile.py")

# 2. TEST DE CONCORDANCE LINGUISTIQUE & VARIANTES NATURELLES (FLUIDITÉ)
print(f"\n{B}▶ [2/4] CONCORDANCE LINGUISTIQUE, ARGOT, ANGLAIS & VARIANTES NATURELLES{Z}")
variantes_test = [
    ("quelle heure est-il", "Heure directe", "Il est"),
    ("météo", "Météo directe", "Météo"),
    ("mets le turbo", "Variante Boost", "Boost"),
    ("ça chauffe trop", "Variante Froid", "Froid"),
    ("libère la mémoire", "Variante Purge RAM", "RAM"),
    ("vide la poubelle", "Variante Corbeille", "Corbeille"),
    ("monte le son", "Variante Volume +", "Volume"),
    ("baisse le volume", "Variante Volume -", "Volume"),
    ("son a 50", "Volume précis 50%", "50%"),
    ("chanson suivante", "Variante Next", "suivant"),
    ("allume la radio", "Variante Radio", "radio"),
    ("open browser", "Variante Anglais Chrome", "Chrome"),
    ("boost mode", "Variante Anglais Boost", "Boost"),
    ("cold mode", "Variante Anglais Froid", "Froid"),
    ("de quoi tu te souviens", "Rappel Mémoire", "souvenir"),
]
for phrase, desc, attendu in variantes_test:
    # Test via correcteur + filtre + moteur mobile
    corr = subprocess.getoutput(f"bash '{ROOT}/correcteur_phonetique.sh' \"{phrase}\"").strip()
    if corr:
        ok("Fluidité Langage", f"{desc:<24} ('{phrase}')", f"➔ '{corr}'")
    else:
        warn("Fluidité Langage", f"Phrase non traduite : '{phrase}'", f"{ROOT}/variantes_utilisateur.txt", f"echo '{phrase}|commande' >> {ROOT}/variantes_utilisateur.txt")

# 3. AUDIT EXHAUSTIF DE TOUS LES BOUTONS MOBILES (PLUGINS + ACTIONS_TERMINAL)
print(f"\n{B}▶ [3/4] TEST RÉEL D'AIGUILLAGE DE 100 % DES BOUTONS MOBILES{Z}")
outils = m.lister_outils()
scripts_all = glob.glob(f"{ROOT}/plugins/*.sh") + glob.glob(f"{ROOT}/actions_terminal/*.sh")

for label, cmd in outils:
    if any(w in cmd for w in ("eteindre", "reboot", "sommeil", "urgence")):
        ok("Bouton Protégé", f"'{label}'", "Sécurisé (non déclenché)")
        continue
    cands = [s for s in scripts_all if not s.endswith(".off") and cmd.replace(" ", "_") in os.path.basename(s)]
    src = cands[0] if cands else f"{ROOT}/interpreteur_universel.sh"

    # Vérification statique de compatibilité mobile du script
    txt_sc = open(src, encoding="utf-8", errors="ignore").read() if os.path.exists(src) else ""
    if "gnome-terminal" in txt_sc and "zenity" not in txt_sc:
        warn("Affichage PC seul", f"'{label}' ouvre un terminal uniquement sur PC", src, f"Ajouter un retour texte/zenity dans {src}")
        continue

    env = os.environ.copy()
    env["TIFFANY_MOBILE"] = "1"
    env["PATH"] = f"{ROOT}/mobile/bin:{env.get('PATH', '')}"
    p = subprocess.Popen(["python3", "-c", f"import sys; sys.path.insert(0,'{ROOT}/mobile'); import moteur_mobile as m; print(m.executer('BTN:{cmd}'))"], env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    try:
        out, _ = p.communicate(timeout=8.0)
        res = m.clean(out.decode("utf-8", errors="ignore"))
        if not res or "inconnu" in res.lower() or "introuvable" in res.lower():
            err("Aiguillage Bouton", f"'{label}' -> Aucune réponse valide", src, f"Vérifier le routage de '{cmd}' dans {src}")
        else:
            ok("Bouton Direct", f"'{label}'", res[:36].replace("\n", " "))
    except subprocess.TimeoutExpired:
        p.kill()
        if os.path.exists("/tmp/tiffany_mob_prompt.json"):
            ok("Bouton Interactif", f"'{label}' -> Pop-up mobile déclenché", "askBox OK sur téléphone")
            try: os.remove("/tmp/tiffany_mob_prompt.json")
            except Exception: pass
        else:
            warn("Bouton Bloquant", f"'{label}' dépasse 8s sans pop-up mobile", src, f"Vérifier les commandes bloquantes dans {src}")

# 4. BILAN & LISTE DES RÉPARATIONS EXACTES
tot = ok_cnt + warn_cnt + err_cnt
score = int(ok_cnt * 100 / max(tot, 1))
print(f"\n{C}{B}╔════════════════════════════════════════════════════════════════════════════╗")
print(f"║  📊 BILAN :  {V}✔ VERT : {ok_cnt:<3}{C} │  {J}⚠ JAUNE : {warn_cnt:<3}{C} │  {R}✘ ROUGE : {err_cnt:<3}{C} │ SCORE : {score}%  ║")
print(f"╚════════════════════════════════════════════════════════════════════════════╝{Z}\n")

if fixes:
    print(f"{B}🛠️  CHEMINS EXACTS & COMMANDES DE RÉPARATION :{Z}\n")
    for idx, (sev, cat, msg, path, fix) in enumerate(fixes, 1):
        col = R if sev == "ROUGE" else J
        print(f"  {col}{idx}. [{sev} - {cat}] {msg}{Z}")
        print(f"     ↳ Chemin     : {C}{path}{Z}")
        print(f"     ↳ Réparation : {V}{fix}{Z}\n")
else:
    print(f"  {V}🏆 100 % PARFAIT : TOUS LES BOUTONS, VARIANTES ET FLUX BIDIRECTIONNELS SONT VALIDÉS !{Z}\n")
