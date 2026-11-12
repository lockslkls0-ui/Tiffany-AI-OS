# 🌹 TIFFANY AI-OS (Version 47.3)
**Système d'Exploitation Hybride, Vocal, Autonome et Souverain pour Linux**

## 🚀 1. PRÉSENTATION DU PROJET
**TIFFANY AI-OS** transforme un ordinateur portable classique (Toshiba Portégé R830 — Intel Core i3-2350M / 8 Go RAM) en une station de travail autonome et vocale. C'est la fusion entre la puissance d'administration de Linux (Bash/Python) et l'intelligence artificielle locale (Ollama), sans dépendance au Cloud.

* **100 % Souveraine et Locale :** Contrairement aux assistants en ligne, Tiffany vit sur le disque dur, pilote le matériel et fonctionne même hors connexion Internet.
* **Calibrée pour les configurations modestes :** Grâce à son cerveau à 3 vitesses et son bouclier thermique Systemd, elle tourne sur un processeur de 2011 sans surchauffe ni blocage.

## 🧠 2. ARCHITECTURE DU CERVEAU À 3 VITESSES
1. **Vitesse 1 — Réflexes Purs (Bash & Mémoire Réflexe, < 0,1s) :** Exécute instantanément les commandes système et les ordres enseignés sans réveiller l'IA.
2. **Vitesse 2 — Discussion Fluide (`tiffany-flash`, ~1,5s) :** Modèle léger avec identité dédiée et interdiction formelle d'inventer des données techniques.
3. **Vitesse 3 — Analyse Profonde (`qwen2.5:1.5b`, 15 à 45s) :** Se déclenche sur les questions complexes (`pourquoi`, `explique`, `diagnostique`, `bug`, `outil`), la recherche web et le Dojo.

## 📋 3. MANUEL D'UTILISATION : COMMANDES DU TERMINAL
* `aide` : Affiche la liste dynamique des outils installés.
* `analyse` / `cpu` / `ram` / `radar` / `wifi` : Diagnostics matériels et réseau en direct.
* `froid` / `boost` : Bride le processeur à 50 % pour refroidir le PC ou libère 100 % de puissance.
* `noyau` / `testia` : Audit des moteurs Ollama, paquets système et intégrité des scripts.
* `cherche [nom]` / `ouvre [nom]` : Localise ou ouvre directement un fichier ou script.
* `crée / supprime / déplace / installe [ordre]` : Génère la commande Linux, demande validation **Zenity** et la mémorise.
* `apprends` / `gerer` : Enseigne, modifie ou supprime visuellement les commandes réflexes.
* `dojo` : Lance une séance d'entraînement autonome dans le bac à sable clos (`~/tiffany/dojo/`).
* `web [sujet]` : Aspire une page web, la résume à voix haute et l'archive dans `contexte_matrice.txt`.
* `webia [question]` : Rédige une fiche encyclopédique complète en direct et la sauvegarde sur le Bureau (`WebIA_Dossiers/`).
* `quitter` : Clôture proprement la session et sauvegarde les souvenirs en arrière-plan.

## 🛡️ 4. PANNEAU GRAPHIQUE & SÉCURITÉS INTÉGRÉES
* **Panneau Graphique (`tiffany_menu.sh`) :** 28 plugins indépendants (système, radio, téléchargeur MP3 avec barre fluide, sauvegarde intelligente anti-Git).
* **Bouclier CPU Systemd :** Plafonne le moteur IA à **80 % de CPU** (`Nice=19`) pour préserver la fluidité du bureau.
* **Sécurité Thermique & Zenity :** Pause automatique du Dojo au-delà de **70°C** et validation humaine obligatoire avant toute action système.
