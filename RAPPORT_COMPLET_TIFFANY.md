# 📘 RAPPORT INTÉGRAL D’ARCHITECTURE & DE CONCEPTION : TIFFANY AI-OS (V47.4)
**Auteur & Créateur :** lockslkls (lockslkls0-ui)
**Dépôt Officiel :** https://github.com
**Système Cible :** Linux (Ubuntu / Linux Mint / Debian — Architecture 64 bits)

## 🌟 1. GENÈSE & PROUESSE TECHNIQUE DU PROJET
**Tiffany AI-OS** est un système d’exploitation hybride, vocal, autonome et 100% local, conçu et assemblé **en quelques jours seulement sans formation préalable en programmation**.
- **Souveraineté & Confidentialité Absolues :** Zéro Cloud, zéro télémétrie, zéro compte requis. Toutes les intelligences artificielles, bases de connaissances et journaux tournent localement sur le disque dur de l'utilisateur.
- **Ingénierie Frugale Haute Performance :** Calibré pour fonctionner avec fluidité sur un processeur modeste (**Intel Core i3-2350M** à 2 cœurs / 4 threads, sans carte graphique dédiée GPU) grâce à une gestion chirurgicale de la mémoire et des cycles processeur.
- **Auto-Évolution Sécurisée :** Tiffany écrit ses propres commandes Bash, les teste en bac à sable (Dojo), demande l'autorisation graphique à son créateur (Zenity) et grave ses réussites dans sa mémoire réflexe.

## ⚙️ 2. OPTIMISATION MATÉRIELLE : TIRER 100% D’UN PC MODESTE
L'un des plus grands exploits de **Tiffany AI-OS** réside dans l'harmonie entre le logiciel et le matériel physique (**Toshiba Portégé R830** — Intel Core i3-2350M, 8 Go RAM DDR3) :
### A. Le Bouclier Thermique & CPU Actif
- **Plafonnement dynamique (cpulimit & Systemd) :** Les calculs d'arrière-plan et les modèles IA sont bridés intelligemment pour ne jamais asphyxier le système.
- **Mode Froid (froid) & Mode Boost (boost) :** Pilotage direct des fréquences et gouverneurs du noyau Linux (/sys/devices/system/cpu/).
- **Sentinelle Thermique (Watchdog) :** Surveillance continue en arrière-plan qui déclenche des alertes et des mesures de protection si la température critique est atteinte.
- **Gestion Chirurgicale de la RAM :** Utilisation de 3 micro-cerveaux spécialisés pesant moins de 2,4 Go au total, complétés par une purge à la demande du cache mémoire (ram).
### B. Lecture Directe des Capteurs de la Carte Mère
Tiffany lit directement les registres du noyau Linux en quelques millisecondes : Température CPU (/sys/class/thermal/), Batterie & Secteur (/sys/class/power_supply/), RAM (free), Stockage (df), Réseau (nmcli), Audio (amixer) et Luminosité (brightnessctl).

## 🧠 3. L’ARCHITECTURE HYBRIDE À 4 ÉTAGES (LE CERVEAU)
### Niveau 1 — Le Système Nerveux Réflexe (< 0,05 seconde — 0% CPU)
- **Fichiers :** reflexes_intelligents.sh, dictionnaire_flash.txt, dictionnaire_ia.txt, actions_terminal/*.sh.
- **Fonctionnement :** Analyse l'intention en Bash pur avant même de solliciter une IA. Effectue le diagnostic vivant (ca va ?), lit les capteurs instantanés et gère l'identité et le surnom dynamique (surnom_utilisateur.txt).
### Niveau 2 — Le Petit Cerveau Fluide (tiffany-flash — 397 Mo)
- **Fonctionnement :** Base qwen2.5:0.5b personnalisée et préchauffée en silence dans la RAM dès l'ouverture pour supprimer toute latence. Assure les conversations naturelles avec injection des capteurs en direct.
### Niveau 3 — Le Gros Cerveau Analytique (qwen2.5:1.5b — 986 Mo)
- **Rôle :** Mobilisé sur les requêtes complexes (explique, diagnostique, souvenir, dossier web) et rédige les synthèses encyclopédiques.
### Niveau 4 — L’Ingénieur Code & Système (qwen2.5-coder:1.5b — 986 Mo)
- **Rôle :** Traduit les demandes en commandes Linux sécurisées par Zenity, anime le Dojo d'auto-entraînement et pilote le Docteur d'audit matériel.

## 🛠️ 4. PANORAMA COMPLET DES OUTILS & FONCTIONNALITÉS
### A. Le Panneau de Contrôle Graphique (tiffany_menu.sh & plugins/)
Interface visuelle regroupant **29 boutons en un clic** : Mode Froid/Boost, Watchdog ON/OFF, Stabilisation Chrome, Diagnostic CPU, Checkup & Purge RAM, Vidage Corbeille, Sauvegarde de la Matrice, Docteur Audit Total, Radio en direct, Téléchargeur YouTube/MP3 (yt-dlp), Filtre Nuit et Contrôle vocal (espeak-ng).
### B. Le Coffre-Fort Double Sécurité (7z + Noyau Linux chattr +i)
Pilotable à la voix et au clavier (cree un dossier securise nomme ... sur bureau) : Validation graphique Zenity préalable, chiffrement intégral par mot de passe (7z -mhe=on) et verrou anti-suppression du noyau Linux (pkexec chattr +i) rendant le fichier immuable jusqu'à l'ordre deverrouille le coffre.
### C. Le Radar Web, le Dojo & La Mémoire Persistante
- **web & webia :** Recherche DuckDuckGo sans navigateur, rédaction de fiches Markdown sur le Bureau et archivage permanent dans connaissances_web.txt.
- **Dojo (tiffany_training.sh) :** Entraînement autonome en bac à sable avec validation Zenity.
- **Archiviste (diary_agent.py) :** Résumé automatique de chaque session à la fermeture dans contexte_matrice.txt et journal_de_bord.txt.

## 🌍 5. DÉPLOIEMENT UNIVERSEL EN 2 COMMANDES (install.sh)
L'installateur universel adapte automatiquement les chemins à n'importe quel ordinateur Linux ($HOME, $USER), installe toutes les dépendances requises (zenity, espeak-ng, cpulimit, p7zip-full, brightnessctl, ddgs, Ollama) et crée le lanceur graphique **🌹 Panneau Tiffany** sur le Bureau.

## 🏆 CONCLUSION
En partant de zéro, **Tiffany AI-OS V47.4** démontre qu'une architecture hybride bien pensée — combinant la vitesse brute du Bash Linux, la précision de Python, la sécurité graphique de Zenity et la spécialisation de petits modèles IA locaux — surpasse en réactivité, en confidentialité et en maîtrise matérielle les assistants classiques, même sur un ordinateur portable modeste.
