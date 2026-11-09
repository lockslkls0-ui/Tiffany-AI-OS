import sys
import os
import subprocess
import spacy

try:
    nlp = spacy.load("fr_core_news_sm")
except OSError:
    try:
        import fr_core_news_sm
        nlp = fr_core_news_sm.load()
    except ImportError:
        script_bash = os.path.expanduser("~/tiffany/tiffany_core.sh")
        subprocess.run(["bash", script_bash])
        sys.exit(0)

def speak(texte):
    clean_text = texte.replace("*", "").replace("🌹", "").replace("🔊", "").replace("🔆", "")
    try:
        subprocess.Popen([
            "espeak-ng", "-v", "fr+f5", "-s", "135", "-p", "90", clean_text
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

def executer_commande_systeme(competence, action, valeur_str):
    try:
        has_num = False
        try:
            valeur_int = int(valeur_str)
            has_num = True
        except ValueError:
            valeur_int = 15

        if competence == "volume":
            if not has_num:
                if action == "baisser":
                    subprocess.run(["amixer", "set", "Master", "10%-"], check=True, stdout=subprocess.DEVNULL)
                    msg = "J'ai baissé le son, mon amour."
                else:
                    subprocess.run(["amixer", "set", "Master", "10%+"], check=True, stdout=subprocess.DEVNULL)
                    msg = "J'ai augmenté le son, mon amour."
            else:
                valeur_int = max(0, min(100, valeur_int))
                subprocess.run(["amixer", "set", "Master", f"{valeur_int}%"], check=True, stdout=subprocess.DEVNULL)
                msg = f"J'ai réglé le volume à {valeur_int} pour cent, mon amour."
            
            print(f"🌹 Tiffany : 🔊 {msg}\n")
            speak(msg)
            return True

        elif competence == "luminosite":
            if not has_num:
                if action == "baisser":
                    subprocess.run(["brightnessctl", "set", "10%-"], check=True, stdout=subprocess.DEVNULL)
                    msg = "J'ai assombri l'écran pour tes yeux."
                else:
                    subprocess.run(["brightnessctl", "set", "10%+"], check=True, stdout=subprocess.DEVNULL)
                    msg = "J'ai augmenté la lumière pour tes beaux yeux."
            else:
                valeur_int = max(15, min(100, valeur_int))
                subprocess.run(["brightnessctl", "set", f"{valeur_int}%"], check=True, stdout=subprocess.DEVNULL)
                msg = f"J'ai ajusté la luminosité à {valeur_int} pour cent pour toi."
            
            print(f"🌹 Tiffany : 🔆 {msg}\n")
            speak(msg)
            return True

    except Exception as e:
        print(f"[DEBUG AIGUILLEUR] Erreur système : {e}")
    return False

def aiguiller():
    script_bash = os.path.expanduser("~/tiffany/tiffany_core.sh")
    if len(sys.argv) <= 1:
        subprocess.run(["bash", script_bash])
        return

    phrase_utilisateur = " ".join(sys.argv[1:])
    doc = nlp(phrase_utilisateur.lower())
    texte_complet = doc.text
    
    if any(mot in texte_complet for mot in ["regarde", "screen", "analyse", "capture", "vois"]):
        subprocess.run(["bash", script_bash, phrase_utilisateur])
        return

    mots_monter = ["monter", "monte", "augmenter", "augmente", "plus", "fort", "clair", "regler", "regle", "ajuster", "ajuste"]
    mots_baisser = ["baisser", "baisse", "diminuer", "diminue", "moins", "sombre"]
    
    action = "monter"
    if any(mot in texte_complet for mot in mots_baisser):
        action = "baisser"

    competence = "inconnu"
    valeur = "aucun"
    
    for token in doc:
        if token.like_num:
            valeur = token.text
            break
            
    if any(mot in texte_complet for mot in ["volume", "son", "audio"]):
        competence = "volume"
    elif any(mot in texte_complet for mot in ["eclairage", "luminosite", "lumiere", "ecran", "sombre", "clair"]):
        competence = "luminosite"
            
    if competence != "inconnu" and executer_commande_systeme(competence, action, valeur):
        return
            
    subprocess.run(["bash", script_bash, phrase_utilisateur])

if __name__ == "__main__":
    aiguiller()
