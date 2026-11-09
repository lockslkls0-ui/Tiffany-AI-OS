#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
import subprocess

def send_tiffany_notification(message, urgency="normal", config_path=None):
    """
    Envoie une notification pop-up visuelle sur le bureau Linux Mint
    en utilisant l'utilitaire natif notify-send.
    """
    if config_path is None:
        config_path = os.path.expanduser("~/tiffany/config_tiffany.json")

    try:
        with open(config_path, "r", encoding="utf-8") as f:
            config = json.load(f)
    except Exception as e:
        return f"⚠️ Erreur de configuration : {str(e)}"

    id_prof = config["identity_profile"]
    
    # Récupération sécurisée de la version (valeur par défaut si absente)
    version_app = config.get("project", {}).get("version", "1.3")
    title = f"🌹 {id_prof['name']} (v{version_app})"
    
    cmd = [
        "notify-send",
        "-u", urgency,
        "-i", "face-kiss",  # Icône système standard et complice
        title,
        message
    ]
    
    try:
        check_util = subprocess.run(["which", "notify-send"], capture_output=True, text=True)
        if check_util.returncode == 0:
            subprocess.run(cmd, check=True)
            return "✅ Notification envoyée sur le bureau avec succès."
        else:
            return "❌ L'utilitaire 'notify-send' n'est pas installé sur ce système Linux."
    except Exception as e:
        return f"❌ Échec de l'envoi de la notification : {str(e)}"

if __name__ == "__main__":
    print("Test du module de notification...")
    result = send_tiffany_notification("Mon système nerveux est connecté, mon créateur... ✨")
    print(result)
