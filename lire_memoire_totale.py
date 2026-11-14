#!/usr/bin/env python3
import os

root = os.path.expanduser("~/tiffany")
mem_dir = os.path.join(root, "memory")
log_dir = os.path.join(root, "logs")

def lire_fin(chemin, max_chars=380):
    if os.path.exists(chemin):
        try:
            with open(chemin, "r", encoding="utf-8", errors="ignore") as f:
                return f.read().strip()[-max_chars:].replace("\n", " | ")
        except Exception:
            pass
    return ""

surnom = lire_fin(os.path.join(mem_dir, "surnom_utilisateur.txt"), 50) or os.getenv("USER", "Utilisateur")
fil_actuel = lire_fin(os.path.join(log_dir, "session_raw.txt"), 450)
journal = lire_fin(os.path.join(mem_dir, "journal_de_bord.txt"), 400)
faits = lire_fin(os.path.join(mem_dir, "long_term_facts.json"), 400)
web = lire_fin(os.path.join(mem_dir, "connaissances_web.txt"), 250)
audit = lire_fin(os.path.join(log_dir, "audit_mistral.log"), 300)
thermique = lire_fin(os.path.join(log_dir, "thermique.log"), 200)

smart = ""
smart_path = os.path.join(log_dir, "sante_disque.txt")
if os.path.exists(smart_path):
    with open(smart_path, "r", errors="ignore") as f:
        lignes = [l.strip() for l in f if any(k in l for k in ["Power_On_Hours", "Reallocated_Sector", "Temperature_Celsius", "UDMA_CRC"])]
        smart = " ; ".join(lignes)

print(
    f"Createur_officiel=Lorian (lockslkls) | "
    f"Utilisateur_actuel={surnom} (compte={os.getenv('USER', 'user')}) | "
    f"Fil_discussion_en_cours={fil_actuel or 'Debut de session'} | "
    f"Faits_memorises={faits or 'Aucun'} | "
    f"Journal_sessions={journal or 'Aucun'} | "
    f"Savoir_Web={web or 'Aucun'} | "
    f"Dernier_audit_erreurs={audit or 'Aucun'} | "
    f"Sante_SMART_disque={smart or 'Non scanne'} | "
    f"Alertes_thermiques={thermique or 'Aucune'}"
)
