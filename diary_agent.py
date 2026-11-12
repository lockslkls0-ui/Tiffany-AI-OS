#!/usr/bin/env python3
import os, subprocess
from datetime import datetime
ROOT_DIR = os.path.expanduser("~/tiffany")
TMP_HISTORY = os.path.join(ROOT_DIR, "logs", "session_raw.txt")
CONTEXTE_MATRICE = os.path.join(ROOT_DIR, "memory", "contexte_matrice.txt")
JOURNAL_BORD = os.path.join(ROOT_DIR, "memory", "journal_de_bord.txt")
horodatage = datetime.now().strftime("%d/%m/%Y à %H:%M")
session = open(TMP_HISTORY, encoding="utf-8").read().strip()[-800:] if os.path.exists(TMP_HISTORY) else ""
rapport = "Session système rapide (commandes directes sans discussion IA)."
if session:
    res = subprocess.run(["nice", "-n", "19", "ollama", "run", "qwen2.5:1.5b", f"Résume en 3 lignes factuelles : [{session}]"], capture_output=True, text=True, timeout=180)
    if res.returncode == 0 and res.stdout.strip(): rapport = res.stdout.strip()
    os.remove(TMP_HISTORY)
open(CONTEXTE_MATRICE, "w", encoding="utf-8").write(f"[SESSION : {horodatage}]\n{rapport}\n")
open(JOURNAL_BORD, "a", encoding="utf-8").write(f"\n=== [{horodatage}] ===\n{rapport}\n")
