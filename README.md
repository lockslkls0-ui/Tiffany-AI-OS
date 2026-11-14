===============================================================================
🌹 TIFFANY AI-OS v48.6 — Assistant Vocal, Hybride & Souverain 100 % Local
===============================================================================

🇫🇷 VERSION FRANÇAISE
-------------------------------------------------------------------------------
Bonjour à tous !

Conçu et testé en 6 jours sur un modeste PC portable Toshiba Portégé R830 (Intel Core i3, 8 Go RAM), Tiffany AI-OS v48.6 est un environnement d'assistance vocale et système 100 % local, souverain, sans cloud et ultra-léger pour Linux (Linux Mint / Ubuntu / Debian).

✨ CE QUE FAIT TIFFANY AI-OS v48.6 :
- 🎙️ Oreille Continue & Réveil Vocal Instantané (Vosk FR) :
  Écoute locale sans abonnement. Répond à la voix (« Tiffany », « Tiff », « Hey ») avec 16 secondes d'écoute enchaînée, anti-mise en veille matérielle et correcteur phonétique adaptatif.
- ⚡ Double Cerveau Hybride (< 0,05 s en Bash + IA locale Ollama) :
  • Réflexes instantanés (< 0,05 s) : 39 boutons graphiques et 28 outils terminal (urgence CPU, volume, luminosité, mode froid/boost, purge RAM/ZRAM, recherche de fichiers, capture d'écran, coffre-fort chiffré AES-256) exécutés sans solliciter le processeur.
  • Cerveaux neuronaux locaux (Ollama) : Modèle rapide (tiffany-flash, 397 Mo) préchargé en RAM pour discuter naturellement, soutenu par qwen2.5:1.5b et qwen2.5-coder:1.5b à la demande.
- 🛡️ Sentinelle Thermique & Santé Matérielle :
  Surveillance continue de la température CPU (systemd), bascule automatique entre mode économie et mode boost, lecture SMART du disque dur et traduction automatique des logs journalctl en français clair.
- 📄 Apprentissage Éclair PDF, Web-IA & Dojo :
  • Extrait, résume et mémorise n'importe quel document PDF en 2 secondes.
  • Recherche sur le web sans navigateur (Web-IA), rédige des fiches complètes sur le Bureau et forge ses propres commandes en bac à sable (Dojo).
  • Livre de Bord graphique intégral (Yad/Zenity) pour lire, ajouter, modifier ou supprimer ses souvenirs en 2 clics.
- ⏰ Planificateur & Réveils Vocaux :
  Programmation d'actions différées à la voix (« coupe la radio dans 20 minutes », « nettoie la RAM à 23h30 ») ou via l'interface graphique.

🔗 CODE SOURCE & INSTALLATION RAPIDE :
Dépôt GitHub officiel : https://:https://github.com/lockslkls0-ui/Tiffany-AI-OS

git clone https://:https://github.com/lockslkls0-ui/Tiffany-AI-OS.git ~/tiffany
cd ~/tiffany && chmod +x install.sh && ./install.sh

N'hésitez pas à tester, forker ou partager vos retours !


===============================================================================
🇬🇧 ENGLISH VERSION
===============================================================================
# 🌹 Tiffany AI-OS v48.6 — 100% Local, Hybrid & Self-Evolving Voice OS for Linux

Hey everyone!

Built and stress-tested in 6 days on a modest Toshiba Portégé R830 laptop (Intel Core i3, 8 GB RAM), Tiffany AI-OS v48.6 is a 100% local, privacy-first, zero-cloud voice assistant and system orchestrator for Linux (Linux Mint / Ubuntu / Debian).

### ✨ What Tiffany AI-OS v48.6 Does:
- 🎙️ Continuous Listening & Instant Voice Wake-Up (Vosk): Offline voice recognition with zero subscriptions, 16-second chained follow-up listening, and an adaptive phonetic corrector.
- ⚡ Hybrid Dual-Brain Architecture (< 0.05s Bash Reflexes + Local Ollama LLMs):
  - Instant Reflex Layer (< 0.05s): 39 GUI tools and 28 CLI commands (CPU emergency stop, volume, brightness, thermal cold/boost modes, RAM/ZRAM purge, fuzzy file search, screenshots, AES-256 encrypted vault).
  - Local Neural Brains (Ollama): Lightweight tiffany-flash (397 MB) kept warm in RAM, backed on demand by qwen2.5:1.5b and qwen2.5-coder:1.5b.
- 🛡️ Thermal Watchdog & Hardware Health: Background systemd thermal sentinel, SMART drive health monitoring, and automatic translation of journalctl errors.
- 📄 Instant PDF Learning, Web-IA & Sandbox Dojo: Extracts and summarizes any PDF in 2 seconds, generates structured Markdown research dossiers without a browser, and safely tests new shell commands in a sandbox.
- ⏰ Voice & GUI Task Scheduler: Schedule delayed commands naturally or via the graphical interface.

### 🔗 Source Code & Quick Install:
Official GitHub Repository: https://:https://github.com/lockslkls0-ui/Tiffany-AI-OS

git clone https://:https://github.com/lockslkls0-ui/Tiffany-AI-OS.git ~/tiffany
cd ~/tiffany && chmod +x install.sh && ./install.sh

Feedback, stars, and forks are warmly welcome!
