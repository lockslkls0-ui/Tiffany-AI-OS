import sys
import json
import spacy

try:
    nlp = spacy.load("fr_core_news_sm")
except OSError:
    print("Erreur : Le modèle français de spaCy n'est pas trouvé.")
    sys.exit(1)

def analyser_phrase(phrase):
    doc = nlp(phrase.lower())
    
    # Dictionnaires de correspondance pour Tiffany
    verbes_volume = ["monter", "baisser", "monte", "baisse", "regler", "regle", "ajuster", "ajuste", "volume", "son"]
    verbes_luminosite = ["eclairage", "luminosite", "lumiere", "sombre", "clair", "ecran"]
    
    competence = "inconnu"
    action = "get"
    valeur = 50
    
    # Extraction des nombres pour les valeurs (ex: 80%)
    for token in doc:
        if token.like_num:
            try:
                valeur = int(token.text)
            except ValueError:
                pass

    # Analyse de la structure grammaticale
    texte_complet = doc.text
    
    if any(mot in texte_complet for mot in verbes_volume):
        competence = "volume"
        action = "set" if any(mot in texte_complet for mot in ["monter", "baisser", "monte", "baisse", "regler", "regle", "set", "ajuste", "ajuster"]) else "get"
    elif any(mot in texte_complet for mot in verbes_luminosite):
        competence = "luminosite"
        action = "set" if any(mot in texte_complet for mot in ["monter", "baisser", "monte", "baisse", "regler", "regle", "set", "ajuste", "ajuster"]) else "get"

    # Construction du JSON structuré attendu par le système
    reponse = {
        "competence": competence,
        "action": action,
        "parametres": {
            "valeur": str(valeur)
        }
    }
    return json.dumps(reponse, ensure_ascii=False)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        phrase_utilisateur = " ".join(sys.argv[1:])
        print(analyser_phrase(phrase_utilisateur))
    else:
        print('{"erreur": "Aucune phrase fournie"}')
