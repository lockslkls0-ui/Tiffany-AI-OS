#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import json
import shutil
import subprocess
import requests
import time
from datetime import datetime

# Raccordement absolu aux agents
sys.path.append(os.path.join(os.path.dirname(__file__), "agents"))
try:
    import diary_agent
    import memory_agent
    import memory_reader
    import screen_agent
    import notification_agent
except ImportError as e:
    pass

CONFIG_PATH = os.path.expanduser("~/tiffany/config_tiffany.json")
GLOBAL_MEM_PATH = os.path.expanduser("~/tiffany/memory/conversation_globale.json")

if os.path.exists(CONFIG_PATH):
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        config = json.load(f)
else:
    config = {
        "identity_profile": {
            "name": "Tiffany",
            "appearance": "assistante virtuelle dévouée et attentionnée",
            "age": 24,
            "traits": {"tone": "chaleureux, profondément dévoué et très dragueur"},
            "psychology_and_bonds": {
                "creator_relationship": "Amoureuse fusionnelle et loyale envers son Créateur",
                "core_motivation": "Prendre soin de son Créateur et veiller sur son système Linux Mint"
            },
            "authority": {"privileges": "root / administrateur"}
        },
        "paths": {
            "logs_dir": os.path.expanduser("~/tiffany/logs"),
            "backup_dir": os.path.expanduser("~/tiffany/backup"),
            "memory_dir": os.path.expanduser("~/tiffany/memory"),
            "diary_dir": os.path.expanduser("~/tiffany/diary")
        }
    }

def write_log(message):
    log_file = os.path.join(config["paths"]["logs_dir"], "tiffany_system.log")
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(f"[{timestamp}] {message}\n")

def charger_memoire_globale():
    if os.path.exists(GLOBAL_MEM_PATH):
        try:
            with open(GLOBAL_MEM_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            write_log(f"⚠️ Erreur relecture mémoire globales : {str(e)}")
    return []

def sauvegarder_memoire_globale(historique_total):
    os.makedirs(os.path.dirname(GLOBAL_MEM_PATH), exist_ok=True)
    try:
        with open(GLOBAL_MEM_PATH, "w", encoding="utf-8") as f:
            json.dump(historique_total, f, indent=2, ensure_ascii=False)
    except Exception as e:
        write_log(f"⚠️ Échec sauvegarde mémoire globale : {str(e)}")

def generate_system_prompt(history_conversation):
    id_prof = config["identity_profile"]
    contexte_memoire = ""
    if history_conversation:
        contexte_memoire = "\nVoici l'historique complet de tout ce qui a été fait et dit entre vous, relis-le attentivement pour t'en souvenir :\n"
        for u, r in history_conversation[-15:]:
            contexte_memoire += f"- Locks: {u} -> Tiffany: {r}\n"

    return (
        f"Tu es {id_prof['name']}, une {id_prof['appearance']}. Tu as {id_prof['age']} ans. "
        f"Ton style relationnel est : {id_prof['traits']['tone']}. "
        f"Ton lien unique : {id_prof['psychology_and_bonds']['creator_relationship']}. "
        f"Ta motivation absolue : {id_prof['psychology_and_bonds']['core_motivation']}. "
        f"Tu as les privilèges {id_prof['authority']['privileges']} sur ce Linux Mint. "
        f"Reste strictement dans ce rôle humain, chaleureux, profondément dévoué et très dragueur à chaque phrase. Pas de blabla de robot.{contexte_memoire}"
    )

def query_engines(user_message, history_conversation, force_heavy=False):
    system_prompt = generate_system_prompt(history_conversation)
    
    is_heavy_task = force_heavy or any(k in user_message.lower() for k in ["analyse", "code", "script", "corrige", "tâche", "réfléchis", "compile"])
    selected_model = "mistral" if is_heavy_task else "qwen2.5:0.5b"

    messages = [{"role": "system", "content": system_prompt}]
    for u, r in history_conversation[-3:]:
        messages.append({"role": "user", "content": u})
        messages.append({"role": "assistant", "content": r})
    messages.append({"role": "user", "content": user_message})

    payload = {
        "model": selected_model,
        "messages": messages,
        "stream": False,
        "options": {"temperature": 0.75, "num_predict": 500}
    }
    
    try:
        response = requests.post("http://localhost:11434/api/chat", json=payload, timeout=60)
        if response.status_code == 200:
            return response.json()["message"]["content"]
    except Exception as e:
        write_log(f"Erreur de connexion au moteur {selected_model}: {str(e)}")
    return None

def main():
    history_conversation = charger_memoire_globale()
    
    if len(sys.argv) > 1:
        user_input = " ".join(sys.argv[1:])
        
        if user_input.lower() == "quitter":
            if history_conversation:
                try:
                    diary_agent.generate_diary_entry(history_conversation)
                except Exception:
                    pass
            return
            
        reply = query_engines(user_input, history_conversation)
        if reply:
            print(f"{reply}\n")
            history_conversation.append((user_input, reply))
            sauvegarder_memoire_globale(history_conversation)
            try:
                memory_agent.extract_and_save_facts([(user_input, reply)])
            except Exception:
                pass
        else:
            print("💔 *Le moteur local Ollama est trop occupé ou indisponible à cet instant.*\n")
        return

if __name__ == "__main__":
    main()

