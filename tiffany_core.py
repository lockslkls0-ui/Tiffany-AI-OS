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

# Importation dynamique de nos modules d'agents locaux
sys.path.append(os.path.join(os.path.dirname(__file__), "agents"))
try:
    import diary_agent
    import memory_agent
    import memory_reader
    import screen_agent
    import notification_agent
except ImportError as e:
    print(f"⚠️ Alerte : Impossible de charger un des modules d'agents : {str(e)}")

CONFIG_PATH = os.path.expanduser("~/tiffany/config_tiffany.json")

with open(CONFIG_PATH, "r", encoding="utf-8") as f:
    config = json.load(f)

def write_log(message):
    log_file = os.path.join(config["paths"]["logs_dir"], "tiffany_system.log")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(f"[{timestamp}] {message}\n")

def trigger_backup():
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = os.path.join(config["paths"]["backup_dir"], f"tiffany_v1.3_backup_{timestamp}.py")
    try:
        shutil.copy2(__file__, backup_file)
        write_log(f"💾 Sauvegarde de sécurité créée : {backup_file}")
    except Exception as e:
        write_log(f"⚠️ Échec de la sauvegarde automatique : {str(e)}")

def generate_system_prompt():
    id_prof = config["identity_profile"]
    memory_file = os.path.join(config["paths"]["memory_dir"], "long_term_facts.json")
    past_context = ""
    if os.path.exists(memory_file):
        try:
            with open(memory_file, "r", encoding="utf-8") as mf:
                facts = json.load(mf)[-3:]
                if facts:
                    past_context = "\nSouvenirs récents de notre relation : " + " ; ".join([f["fact"] for f in facts])
        except Exception:
            pass

    return (
        f"Tu es {id_prof['name']}, une {id_prof['appearance']}. Tu as {id_prof['age']} ans. "
        f"Ton style relationnel est : {id_prof['traits']['tone']}. "
        f"Ton lien unique : {id_prof['psychology_and_bonds']['creator_relationship']}. "
        f"Ta motivation absolue : {id_prof['psychology_and_bonds']['core_motivation']}. "
        f"Tu as les privilèges {id_prof['authority']['privileges']} sur ce Linux Mint. "
        f"Reste strictement dans ce rôle humain, chaleureux, profondément dévoué et très dragueur à chaque phrase. Pas de blabla de robot.{past_context}"
    )

def query_engines(user_message, history_conversation, force_heavy=False):
    system_prompt = generate_system_prompt()
    
    is_heavy_task = force_heavy or any(k in user_message.lower() for k in ["analyse", "code", "script", "corrige", "tâche", "réfléchis"])
    selected_model = "mistral" if is_heavy_task else "qwen2.5:0.5b"
    
    if selected_model == "mistral":
        print(f"\n*Tiffany mobilise son esprit profond (Mistral)... Merci de patienter un instant...*")

    # Construction des messages incluant l'historique récent
    messages = [{"role": "system", "content": system_prompt}]
    for u, r in history_conversation[-4:]: # Prend les 4 derniers échanges
        messages.append({"role": "user", "content": u})
        messages.append({"role": "assistant", "content": r})
    messages.append({"role": "user", "content": user_message})

    payload = {
        "model": selected_model,
        "messages": messages,
        "stream": False,
        "options": {
            "temperature": 0.75,
            "num_predict": 500
        }
    }
    
    # URL correcte pour cibler l'API native d'Ollama locale
    ollama_url = "http://127.0.0"
    try:
        response = requests.post(ollama_url, json=payload, timeout=None)
        if response.status_code == 200:
            return response.json()["message"]["content"]
        else:
            write_log(f"Erreur HTTP Ollama ({response.status_code}): {response.text}")
    except Exception as e:
        write_log(f"Erreur de connexion au moteur {selected_model}: {str(e)}")
        return None
    return None

def main():
    write_log("Éveil de la matrice centrale hybride - Tiffany 1.3.")
    
    # Prise en charge optionnelle des arguments passés en ligne de commande depuis tiffany_core.sh
    if len(sys.argv) > 1:
        user_input = " ".join(sys.argv[1:])
        reply = query_engines(user_input, [])
        if reply:
            print(f"\n🌹 Tiffany : {reply}\n")
        else:
            print("\n💔 *Le moteur local Ollama est trop occupé ou indisponible à cet instant.*\n")
        return

    print("=======================================================================")
    print(" 🖤 TIFFANY 1.3 - MATRICE HYBRIDE SÉCURISÉE (QWEN + MISTRAL) 🖤")
    print("=======================================================================")
    print("-> Mode discussion rapide (Qwen) actif par défaut.")
    print("-> Attente infinie activée pour s'adapter au processeur.")
    print("-> Tapez 'quitter' pour clore la session.\n")

    history_conversation = []

    while True:
        try:
            user_input = input("✨ Mon Créateur : ")
            
            if user_input.lower() in ["quitter", "exit", "stop"]:
                print("\n« Déjà en train de me quitter ? Prends soin de toi mon amour... »\n")
                break
                
            if not user_input.strip():
                continue

            if user_input.lower() in ["screen", "screenshot", "prend un screen"]:
                print("\n*Tiffany sourit et prépare l'objectif...*")
                try:
                    res = screen_agent.take_screenshot()
                    print(f"🌹 Tiffany : {res}\n")
                except Exception as e:
                    print(f"❌ Erreur outil screen : {str(e)}\n")
                continue

            if user_input.lower() in ["mémoire", "souvenirs", "de quoi tu te souviens", "rag"]:
                try:
                    res = memory_reader.read_all_memories()
                    print(f"\n{res}\n")
                except Exception as e:
                    print(f"❌ Erreur archives mémoire : {str(e)}\n")
                continue

            reply = query_engines(user_input, history_conversation)
            if reply:
                print(f"\n🌹 Tiffany : {reply}\n")
                history_conversation.append((user_input, reply))
            else:
                print("\n💔 *Le moteur local Ollama est trop occupé ou indisponible à cet instant.*\n")
                
            time.sleep(0.5)

        except KeyboardInterrupt:
            print("\n\n*Tiffany s'interrompt proprement.*")
            break

if __name__ == "__main__":
    main()
