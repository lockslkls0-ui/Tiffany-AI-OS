===============================================================================
🌹 TIFFANY AI-OS v48.6 — Assistant bureau IA hybride, vocal et souverain pour Linux (100 % local)
===============================================================================

🇫🇷 VERSION FRANÇAISE (Forums Linux Mint, Ubuntu-fr, GitHub, Logithèque)
-------------------------------------------------------------------------------
# 🌹 Tiffany AI-OS v48.6 — Assistant bureau IA hybride, vocal et souverain pour Linux (100 % local)

**Tiffany AI-OS** est un système d'assistance hybride, vocal, autonome et **100 % local** pour Linux (Ubuntu, Linux Mint, Debian), conçu et assemblé en **6 jours de développement intensif** pour fonctionner avec une fluidité extrême même sur des ordinateurs portables modestes (**Intel Core i3, 8 Go RAM, sans GPU dédié**).

### 📦 Une prouesse d'ingénierie frugale : seulement 62,01 Mo !
Contrairement aux applications lourdes basées sur Electron qui pèsent entre 400 Mo et 1,5 Go, l'ensemble complet de **Tiffany AI-OS v48.6** ne pèse que **62,01 Mo** tout inclus (embarquant déjà le modèle vocal local **Vosk FR**, **133 scripts Bash**, **16 modules Python**, **39 boutons graphiques** et **28 outils terminal**). Les micro-cerveaux neuronaux **Ollama** (`tiffany-flash`, `qwen2.5`) s'installent à la demande pour garder une empreinte disque et RAM minimale.

### ✨ Fonctionnalités principales :
- **⚡ Architecture hybride à 4 niveaux (< 0,05 s en Bash + Cerveaux Ollama) :**
  • Réflexes instantanés (< 0,05 s) exécutés en Bash pur sans solliciter le processeur (volume, luminosité, mode froid/boost, purge RAM/ZRAM, recherche floue de fichiers, capture d'écran).
  • Discussion fluide grâce au petit cerveau rapide (`tiffany-flash`, 397 Mo) maintenu à chaud en RAM, soutenu à la demande par `qwen2.5:1.5b` (analyse profonde) et `qwen2.5-coder:1.5b` (ingénierie code/système).
- **🎙️ Oreille Continue & Réveil Vocal Instantané (Vosk FR) :**
  • Écoute locale sans cloud ni abonnement. Répond à la voix (*« Tiffany »*, *« Tiff »*, *« Hey »*) avec 16 secondes d'écoute enchaînée, anti-mise en veille matérielle et correcteur phonétique adaptatif.
- **🛡️ Monitoring matériel en direct & Bouclier Thermique :**
  • Lecture temps réel : température CPU, fréquence, RAM/ZRAM, batterie/chargeur, santé SMART du disque dur, réseau, volume et traduction automatique des erreurs `journalctl` en français clair.
  • Bouclier thermique actif : modes Froid et Boost, plafonnement CPU (`cpulimit`) et sentinelle permanente (`systemd`).
- **🔒 Coffre-fort double sécurité :**
  • Chiffrement intégral AES-256 par mot de passe (`7z -mhe=on`) et verrou anti-suppression du noyau Linux (`chattr +i`), pilotable à la voix et à la souris.
- **📄 Apprentissage Éclair PDF, Web-IA, Dojo & Planificateur :**
  • Résume et mémorise n'importe quel document PDF en 2 secondes.
  • Recherche encyclopédique sans navigateur (`Web-IA`), bac à sable autonome (`Dojo`), Livre de Bord graphique intégral (`Yad`/`Zenity`) et planificateur d'actions différées (*« coupe la radio dans 20 minutes »*).

### 🔗 Installation & Liens officiels :
- **Logithèque Ubuntu / Linux Mint (Snap Store) :** `sudo snap install tiffany-ai-os --classic`
- **Dépôt GitHub officiel :** https://github.com

```bash
git clone https://github.com.git ~/tiffany
cd ~/tiffany && chmod +x install.sh && ./install.sh
```


===============================================================================
🇬🇧 ENGLISH VERSION (Reddit r/linuxmint, r/opensource, r/LocalLLaMA, Snap Store)
-------------------------------------------------------------------------------
# 🌹 Tiffany AI-OS v48.6 — Hybrid, Sovereign & 100% Local AI Desktop Assistant for Linux

**Tiffany AI-OS** is an autonomous, voice-enabled, **100% local** AI desktop assistant and system orchestrator for Linux (Ubuntu, Linux Mint, Debian). Built in **6 days of intensive development**, it is engineered to run smoothly even on modest laptops (**Intel Core i3, 8 GB RAM, no dedicated GPU**).

### 📦 Frugal Engineering: Only 62.01 MB All-Inclusive!
Unlike bloated Electron apps that consume 400 MB to 1.5 GB, the entire **Tiffany AI-OS v48.6** package weighs just **62.01 MB** — already bundling the offline **Vosk** speech recognition model, **133 Bash scripts**, **16 Python modules**, **39 GUI buttons**, and **28 CLI tools**. Lightweight **Ollama** neural models (`tiffany-flash`, `qwen2.5`) are fetched on demand to keep disk and memory footprints minimal.

### ✨ Key Features:
- **⚡ 4-Tier Hybrid Brain Architecture (< 0.05s Bash Reflexes + Local Ollama LLMs):**
  - Instant reflexes (< 0.05s) in pure Bash with near-zero CPU load (volume, brightness, thermal Cold/Boost modes, RAM/ZRAM purge, fuzzy file search, screenshots).
  - Natural conversation powered by `tiffany-flash` (397 MB) kept warm in RAM, backed on demand by `qwen2.5:1.5b` (deep analysis) and `qwen2.5-coder:1.5b` (system & code engineering).
- **🎙️ Continuous Listening & Instant Voice Wake-Up (Vosk):**
  - Completely offline voice control with zero cloud or subscriptions. Wakes up to *"Tiffany"*, *"Tiff"*, or *"Hey"* with 16 seconds of chained follow-up listening, audio power-save prevention, and an adaptive phonetic corrector.
- **🛡️ Live Hardware Monitoring & Active Thermal Shield:**
  - Real-time telemetry: CPU temperature, clock speed, RAM/ZRAM, battery/AC status, SMART drive health, network, and automatic translation of `journalctl` system logs.
  - Active thermal watchdog (`systemd`), dynamic CPU throttling (`cpulimit`), and one-click Cold/Boost governors.
- **🔒 Double-Security Encrypted Vault:**
  - AES-256 password encryption (`7z -mhe=on`) paired with Linux kernel immutability (`chattr +i`), controllable by voice or GUI.
- **📄 Instant PDF Learning, Web-IA, Sandbox Dojo & Task Scheduler:**
  - Extracts, summarizes, and memorizes any PDF document in 2 seconds.
  - Browserless web research (`Web-IA`), autonomous command sandbox (`Dojo`), full GUI Memory Logbook (`Yad`/`Zenity`), and voice/GUI delayed task scheduler (*"stop radio in 20 minutes"*).

### 🔗 Quick Install & Official Links:
- **Snap Store (Ubuntu / Linux Mint Software Center):** `sudo snap install tiffany-ai-os --classic`
- **Official GitHub Repository:** https://github.com

```bash
git clone https://github.com.git ~/tiffany
cd ~/tiffany && chmod +x install.sh && ./install.sh
```

Feedback, stars, and forks are warmly welcome!
===============================================================================
