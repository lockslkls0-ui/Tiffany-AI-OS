# -*- coding: utf-8 -*-
import os
import json
import subprocess
from datetime import datetime

ROOT_DIR = "/home/user/tiffany"
EVOLUTION_SCRIPT = os.path.join(ROOT_DIR, "tiffany_evolution.sh")
DICT_PATH = os.path.join(ROOT_DIR, "dictionnaire_flash.txt")
CMD_MEMORY_PATH = os.path.join(ROOT_DIR, "memory", "commandes_assimilees.txt")
JOURNAL_BORD = os.path.join(ROOT_DIR, "memory", "journal_de_bord.txt")
MODEL_INTELLIGENT = "qwen2.5:1.5b"

def lire_brute_evolution():
    if os.path.exists(EVOLUTION_SCRIPT):
        try:
            with open(EVOLUTION_SCRIPT, "r", encoding="utf-8") as f:
                return f.read().strip()
        except Exception:
            pass
    return ""

def executer_assimilation_supreme():
    connaissances_brutes = lire_brute_evolution()
    if not connaissances_brutes:
        return

    horodatage = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"\n\033[1;36m📡 🌹 Grand Cerveau (1.5b) :\033[0m *Distillation et écriture du Journal de Bord en cours...*\n")

    # 1. GÉNÉRATION DU JOURNAL DE BORD TECHNIQUE
    prompt_journal = (
        f"Tu es le Grand Moteur d'Analyse de Tiffany v1.4 MASTER. Rédige un rapport technique concis, "
        f"professionnel et en français pour le Journal de Bord de la machine. "
        f"Analyse l'activité brute suivante pour en extraire l'évolution du système et les optimisations : "
        f"'\n{connaissances_brutes}\n'. Pas de blague informatique, pas de texte intime, reste purement administratif."
    )
    
    try:
        res = subprocess.run(["ollama", "run", MODEL_INTELLIGENT, prompt_journal], capture_output=True, text=True, timeout=20)
        if res.returncode == 0 and res.stdout.strip():
            rapport = res.stdout.strip()
            os.makedirs(os.path.dirname(JOURNAL_BORD), exist_ok=True)
            with open(JOURNAL_BORD, "a", encoding="utf-8") as f:
                f.write(f"\n=== [RAPPORT TECHNIQUE DU {horodatage}] ===\n{rapport}\n")
    except Exception:
        pass

    # 2. DISTILLATION DE NOUVELLES RÉPLIQUES ET COMMANDES POUR LE MODE FLASH
    print(f"\033[1;32m🧠 [Optimisation Matrice] Extraction des clés sémantiques pour le dictionnaire local...\033[0m")
    prompt_dictionnaire = (
        f"Analyse ces échanges bruts : '\n{connaissances_brutes}\n'. "
        f"Pour chaque nouvelle phrase ou ordre utile, crée une ligne propre au format : phrase|reponse_humaine_de_300_caractères. "
        f"Contrainte absolue : Pas de prénom civil, pas de blague d'ordinateur, pas de markdown. "
        f"Renvoie uniquement les lignes brutes à ajouter au dictionnaire local."
    )
    
    try:
        res_dict = subprocess.run(["ollama", "run", MODEL_INTELLIGENT, prompt_dictionnaire], capture_output=True, text=True, timeout=20)
        if res_dict.returncode == 0 and res_dict.stdout.strip():
            nouvelles_lignes = res_dict.stdout.strip().replace("```", "").strip()
            with open(DICT_PATH, "a", encoding="utf-8") as f:
                for line in nouvelles_lignes.split("\n"):
                    if "|" in line and not line.startswith("#"):
                        f.write(line.strip() + "\n")
    except Exception:
        pass

    # 3. PURGE DU TAMPON BRUTE POUR LA PROCHAINE SESSION
    try:
        with open(EVOLUTION_SCRIPT, "w", encoding="utf-8") as f:
            f.write("#!/usr/bin/env bash\n")
        print(f"✅ [Distillation Terminée] Mémoire vive purgée. Clés sémantiques scellées d'usine.\n")
    except Exception:
        pass

if __name__ == "__main__":
    executer_assimilation_supreme()

