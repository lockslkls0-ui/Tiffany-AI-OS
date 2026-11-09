#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import subprocess
import time

def speak(texte):
    clean = texte.replace("*", "").replace("🌹", "").replace("🔊", "").replace("🔆", "").replace("🔋", "").replace("🕒", "").replace("🎬", "").replace("🌡️", "")
    try:
        # On lance le processus de parole
        p = subprocess.Popen(["espeak-ng", "-v", "fr+f5", "-s", "135", "-p", "90", clean], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        # On laisse le temps à espeak de lire la phrase avant que le script Python ne s'arrête brutalement
        p.wait()
    except Exception:
        pass

def gerer_outils(phrase):
    phrase_lower = phrase.lower()
    ROOT_DIR = os.path.expanduser("~/tiffany")
    
    if any(mot in phrase_lower for mot in ["heure", "horloge", "quelle heure"]):
        subprocess.run(["bash", os.path.join(ROOT_DIR, "tiffany_outils.sh"), "heure"])
        return True

    if any(mot in phrase_lower for mot in ["météo", "meteo", "quel temps"]):
        subprocess.run(["bash", os.path.join(ROOT_DIR, "tiffany_outils.sh"), "meteo"])
        return True

    if any(mot in phrase_lower for mot in ["batterie", "energie", "énergie"]):
        cap = "inconnue"
        # Lecture propre et sécurisée avec fermeture automatique des fichiers
        if os.path.exists("/sys/class/power_supply/BAT0/capacity"):
            try:
                with open("/sys/class/power_supply/BAT0/capacity", "r") as f:
                    cap = f.read().strip()
            except Exception:
                pass
        elif os.path.exists("/sys/class/power_supply/BAT1/capacity"):
            try:
                with open("/sys/class/power_supply/BAT1/capacity", "r") as f:
                    cap = f.read().strip()
            except Exception:
                pass

        msg = f"Ton Toshiba Portege est à {cap} pour cent d'énergie, mon ange."
        print(f"\n🌹 Tiffany : 🔋 {msg}\n")
        speak(msg)
        return True
        
    return False
