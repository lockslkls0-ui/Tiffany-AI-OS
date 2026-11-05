# 🌹 Tiffany AI-OS v38.0 - Assistante IA Privée & Admin Linux

Bienvenue dans l'écosystème officiel de **Tiffany**, un prototype d'**Agent d'Action IA Local (Desktop Companion)** conçu et propulsé sous la distribution **LocksLks**. 

Tiffany transforme votre système Linux Mint / Ubuntu en une interface augmentée, capable de communiquer à voix haute, de s'auto-nettoyer, de réguler sa température et d'obéir instantanément à vos instructions en texte libre, le tout de manière **100 % privée, locale et sans aucune connexion Internet**.

## ⚡ L'Innovation du Prototype : L'Architecture Hybride
Pour éliminer la latence sur les configurations portables légères, Tiffany intègre un **Moteur d'Interception Flash** :
- **Ordres Courants (Moins de 0,1s) :** Les demandes comme "crée dossier", "ram", "nettoyer système" ou "météo" sont interceptées nativement en Bash pour une réactivité instantanée.
- **Ordres Complexes :** L'application passe automatiquement la main à un serveur d'IA local (**Ollama Llama3 / Qwen**) pour décoder les syntaxes Linux pointues.
- **Sécurité Totale :** Aucune action générée par l'IA ne s'exécute dans votre ombre. Un pop-up graphique **Zenity** surgit systématiquement pour vous montrer la commande et attendre votre clic d'autorisation.

## 📦 Installation d'Usine

1. Extrayez l'archive dans votre dossier personnel afin que l'adresse exacte soit : `/home/VOTRE_NOM/tiffany`.
2. Ouvrez un terminal à l'intérieur du dossier et lancez le script de déploiement automatique :
   ```bash
   ./install.sh
   ```
*Ce script installera l'intégralité des dépendances système (Espeak-ng, Rhythmbox, Tesseract) et téléchargera le modèle d'IA local.*

## 🎮 Utilisation

Pour piloter l'application, double-cliquez simplement sur le fichier **`tiffany_menu.sh`** (ou lancez-le en terminal). 

Ce panneau de contrôle graphique vous permet d'ouvrir l'invite de discussion interactive ("Parler à Tiffany"), de surveiller votre processeur, de basculer en mode Boost (2.2+ GHz) ou d'écouter vos radios favorites directement dans Rhythmbox.

## 📄 Fiche Technique & Soutien
Pour découvrir l'architecture logicielle complète et minutieuse du prototype, ouvrez le fichier `fiche_technique_tiffany.txt` situé à la racine du dossier. Vous y trouverez également le mot de remerciement officiel du Créateur ainsi que le lien de la cagnotte pour soutenir le développement de la distribution **LocksLks** !


