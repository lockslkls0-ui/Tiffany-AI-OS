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
        subprocess.Popen(["espeak-ng", "-v", "fr+f5", "-s", "135", "-p", "90", clean_text], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

def executer_commande_systeme(competence, valeur):
    try:
        valeur_int = int(valeur)
        if competence == "volume":
            valeur_int = max(0, min(100, valeur_int))
            subprocess.run(["amixer", "set", "Master", f"{valeur_int}%"], check=True, stdout=subprocess.DEVNULL)
            msg = f"J'ai réglé le volume à {valeur_int} pour cent, mon amour."
            print(f"🌹 Tiffany : 🔊 {msg}\n")
            speak(msg)
            return True
        elif competence == "luminosite":
            valeur_int = max(15, min(100, valeur_int))
            subprocess.run(["brightnessctl", "set", f"{valeur_int}%"], check=True, stdout=subprocess.DEVNULL)
            msg = f"J'ai ajusté la luminosité à {valeur_int} pour cent pour tes beaux yeux."
            print(f"🌹 Tiffany : 🔆 {msg}\n")
            speak(msg)
            return True
    except Exception:
        pass
    return False

def aiguiller():
    script_bash = os.path.expanduser("~/tiffany/tiffany_core.sh")
    
    if len(sys.argv) <= 1:
        subprocess.run(["bash", script_bash])
        return

    phrase_utilisateur = " ".join(sys.argv[1:])
    doc = nlp(phrase_utilisateur.lower())
    
    verbes_volume = ["monter", "baisser", "monte", "baisse", "regler", "regle", "ajuster", "ajuste", "volume", "son"]
    # CORRECTION : On retire "écran" ici pour éviter qu'il n'écrase la commande de capture d'écran
    verbes_luminosite = ["eclairage", "luminosite", "lumiere", "sombre", "clair"]
    
    competence = "inconnu"
    valeur = "50"
    
    for token in doc:
        if token.like_num:
            valeur = token.text

    texte_complet = doc.text
    
    # Si la phrase contient "regarde" ou "screen" ou "analyse", on ignore la luminosité matérielle directe
    if any(mot in texte_complet for mot in ["regarde", "screen", "analyse", "capture"]):
        competence = "inconnu"
    else:
        if any(mot in texte_complet for mot in verbes_volume):
            competence = "volume"
        elif any(mot in texte_complet for mot in verbes_luminosite):
            competence = "luminosite"

    if competence != "inconnu":
        if executer_commande_systeme(competence, valeur):
            return

    subprocess.run(["bash", script_bash, phrase_utilisateur])

if __name__ == "__main__":
    aiguiller()
