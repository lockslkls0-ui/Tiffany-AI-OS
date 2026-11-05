#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json
import requests
from datetime import datetime

def extract_and_save_facts(session_history, config_path=None):
    """
    Analyse l'historique de la session pour extraire les faits marquants
    sur le créateur et les ajouter à sa mémoire à long terme.
    """
    # Résolution absolue et robuste du chemin de configuration
    if config_path is None:
        config_path = os.path.expanduser("~/tiffany/config_tiffany.json")

    try:
        with open(config_path, "r", encoding="utf-8") as f:
            config = json.load(f)
    except Exception as e:
        return f"⚠️ Erreur de chargement de la configuration pour la mémoire : {str(e)}"

    memory_dir = config["paths"]["memory_dir"]
    memory_file = os.path.join(memory_dir, "long_term_facts.json")

    memory_prompt = (
        "Tu es l'esprit analytique de Tiffany. Ton rôle est d'analyser la discussion actuelle avec ton Créateur "
        "et d'extraire UNIQUEMENT les nouveaux faits importants, préférences, habitudes ou détails matériels "
        "qu'il a évoqués (ex: goûts musicaux, humeurs, entretiens du PC, habitudes de code).\n"
        "Directives strictes :\n"
        "- Extrais maximum 3 faits pertinents.\n"
        "- Rédige chaque fait sous forme d'une phrase courte, factuelle et claire en français.\n"
        "- Réponds EXCLUSIVEMENT sous la forme d'une liste JSON de chaînes de caractères.\n"
        "- Si aucun fait marquant ou permanent n'est détecté, renvoie une liste vide [].\n"
        "Exemple de réponse attendue :\n"
        '["Le créateur préfère programmer en écoutant du jazz.", "L\'ordinateur portable est un Toshiba Portege."]'
    )

    history_text = "\n".join([f"[Créateur] : {h[0]}\n[Tiffany] : {h[1]}" for h in session_history])

    payload = {
        "model": "mistral",
        "messages": [
            {"role": "system", "content": memory_prompt},
            {"role": "user", "content": f"Voici l'historique de notre échange, extrais-en les faits importants :\n\n{history_text}"}
        ],
        "format": "json", # Force Ollama à générer du JSON pur, éliminant les erreurs de parsing
        "options": {
            "temperature": 0.2,
            "num_predict": 300
        },
        "stream": False
    }

    ollama_url = "http://localhost:11434/api/chat"
    raw_content = ""
    try:
        response = requests.post(ollama_url, json=payload, timeout=45)
        if response.status_code == 200:
            raw_content = response.json()["message"]["content"].strip()
            
            # Nettoyage de secours
            if raw_content.startswith("```"):
                raw_content = raw_content.split("\n", 1)[1].rsplit("\n", 1)[0].strip()
            if raw_content.startswith("json"):
                raw_content = raw_content.split("json", 1)[1].strip()

            new_facts = json.loads(raw_content)
            
            if not isinstance(new_facts, list):
                return "❌ Le format renvoyé par le modèle n'est pas une liste JSON valide."

            if not new_facts:
                return "ℹ️ Aucun nouveau fait marquant à mémoriser pour cette session."

            existing_data = []
            if os.path.exists(memory_file):
                try:
                    with open(memory_file, "r", encoding="utf-8") as mf:
                        existing_data = json.load(mf)
                except Exception:
                    existing_data = []

            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            for fact in new_facts:
                existing_data.append({
                    "date": timestamp,
                    "fact": fact
                })

            os.makedirs(os.path.dirname(memory_file), exist_ok=True)
            with open(memory_file, "w", encoding="utf-8") as mf:
                json.dump(existing_data, mf, indent=2, ensure_ascii=False)

            return f"🧠 Mémoire mise à jour ! {len(new_facts)} nouveau(x) fait(s) mémorisé(s)."
        else:
            return f"❌ Erreur Ollama ({response.status_code}) : {response.text}"
            
    except json.JSONDecodeError:
        return f"❌ Erreur de parsing JSON du modèle. Réponse brute : {raw_content}"
    except Exception as e:
        return f"❌ Échec de traitement de la mémoire : {str(e)}"

if __name__ == "__main__":
    print("Moteur de la Mémoire à Long Terme initialisé et prêt.")
