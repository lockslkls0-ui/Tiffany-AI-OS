#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json
import subprocess
from datetime import datetime

def take_screenshot(config_path=None):
    """
    Exécute un outil de capture d'écran natif sous Linux Mint
    et sauvegarde l'image dans l'arborescence du projet.
    """
    if config_path is None:
        config_path = os.path.expanduser("~/tiffany/config_tiffany.json")

    try:
        with open(config_path, "r", encoding="utf-8") as f:
            config = json.load(f)
    except Exception as e:
        return f"⚠️ Erreur de chargement de la configuration pour le screen : {str(e)}"

    # Définition sécurisée du dossier racine de l'application (valeur de secours)
    base_dir = os.path.expanduser("~/tiffany")
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    screenshot_name = f"tiffany_screen_{timestamp}.png"
    screenshot_path = os.path.join(base_dir, screenshot_name)

    # Liste des utilitaires de capture d'écran natifs sous Linux Mint
    utilities = ["gnome-screenshot", "scrot", "xfce4-screenshooter"]
    success = False
    used_utility = ""

    for util in utilities:
        check_util = subprocess.run(["which", util], capture_output=True, text=True)
        if check_util.returncode == 0:
            used_utility = util
            if util == "gnome-screenshot":
                cmd = ["gnome-screenshot", "-f", screenshot_path]
            elif util == "scrot":
                cmd = ["scrot", screenshot_path]
            elif util == "xfce4-screenshooter":
                cmd = ["xfce4-screenshooter", "-s", screenshot_path]
            
            try:
                # Execution en arrière-plan sans bloquer l'interface
                subprocess.run(cmd, capture_output=True, check=True)
                success = True
                break
            except subprocess.CalledProcessError:
                continue

    if success:
        return f"📸 Capture d'écran effectuée avec succès via {used_utility} ! Enregistrée sous : {screenshot_path}"
    else:
        return "❌ Aucun utilitaire de capture (gnome-screenshot, scrot, xfce4-screenshooter) n'est disponible ou fonctionnel sur ce Linux."

if __name__ == "__main__":
    print("Test du module de capture d'écran...")
    result = take_screenshot()
    print(result)
