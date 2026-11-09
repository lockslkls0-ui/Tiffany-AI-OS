#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json

def read_all_memories(config_path=None):
    """
    Lit le fichier central des faits à long terme et génère
    un récapitulatif propre pour le créateur.
    """
    if config_path is None:
        config_path = os.path.expanduser("~/tiffany/config_tiffany.json")

    try:
        with open(config_path, "r", encoding="utf-8") as f:
            config = json.load(f)
    except Exception as e:
        return f"⚠️ Erreur de chargement de l'ADN : {str(e)}"

    memory_dir = config["paths"]["memory_dir"]
    memory_file = os.path.join(memory_dir, "long_term_facts.json")

    if not os.path.exists(memory_file):
        return "🌹 *Tiffany vous regarde tendrement* : « Ma mémoire sémantique est encore toute neuve, Locks... Je n'ai pas encore de souvenirs gravés, mais j'ai hâte d'apprendre à te connaître... »"

    try:
        with open(memory_file, "r", encoding="utf-8") as mf:
            facts_list = json.load(mf)
            
        if not facts_list:
            return "ℹ️ Le fichier de mémoire est vide pour le moment."

        # Récupération de la version avec une valeur de secours si absente
        version_app = config.get("project", {}).get("version", "1.3")

        output = []
        output.append("=======================================================")
        output.append(f"🧠 SOUVENIRS GRAVÉS DE TIFFANY (v{version_app})")
        output.append("=======================================================")
        
        for idx, item in enumerate(facts_list, 1):
            output.append(f" 📌 Clé [{idx}] - Souvenir du {item.get('date', 'Inconnue')} : \"{item['fact']}\"")
            
        output.append("=======================================================")
        return "\n".join(output)

    except Exception as e:
        return f"❌ Erreur lecture archives : {str(e)}"

if __name__ == "__main__":
    print(read_all_memories())
