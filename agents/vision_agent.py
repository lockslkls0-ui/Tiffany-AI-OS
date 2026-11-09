#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import glob
import subprocess

def analyze_last_screenshot():
    """
    Trouve la dernière capture d'écran PNG générée, extrait le texte
    via Tesseract OCR et renvoie le texte brut trouvé.
    """
    # Recherche robuste des captures d'écran à la racine du projet
    root_dir = os.path.expanduser("~/tiffany")
    png_files = glob.glob(os.path.join(root_dir, "tiffany_screen_*.png"))
    
    if not png_files:
        return "❌ Aucune capture d'écran récente trouvée à analyser."
        
    # Sélection de la capture la plus récente
    last_screen = max(png_files, key=os.path.getctime)
    
    # Identifiant unique temporaire pour éviter les conflits d'écriture
    output_base = os.path.join(root_dir, "tiffany_extracted_tmp")
    result_file = f"{output_base}.txt"
    
    # Exécution de Tesseract OCR en français
    cmd = ["tesseract", last_screen, output_base, "-l", "fra"]
    
    try:
        # Vérification préalable si tesseract est présent
        check_tess = subprocess.run(["which", "tesseract"], capture_output=True, text=True)
        if check_tess.returncode != 0:
            return "❌ L'utilitaire 'tesseract-ocr' n'est pas installé sur ce système Linux. (Fais 'sudo apt install tesseract-ocr tesseract-ocr-fra')"

        subprocess.run(cmd, capture_output=True, check=True)
        
        if os.path.exists(result_file):
            with open(result_file, "r", encoding="utf-8") as f:
                extracted_text = f.read().strip()
            
            # Nettoyage systématique après lecture réussie
            os.remove(result_file)
            
            if not extracted_text:
                return "ℹ️ L'image est floue ou ne contient aucun texte lisible."
                
            return extracted_text
            
    except Exception as e:
        # Nettoyage de sécurité en cas de plantage au milieu de l'OCR
        if os.path.exists(result_file):
            os.remove(result_file)
        return f"❌ Échec de l'analyse optique : {str(e)}"
    
    return "❌ Impossible de récupérer les données textuelles."

if __name__ == "__main__":
    print("Analyse de la dernière capture d'écran...")
    print(analyze_last_screenshot())
