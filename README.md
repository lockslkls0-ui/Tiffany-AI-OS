===============================================================================
🌹 TIFFANY AI-OS v48.6 — Assistant Vocal, Hybride & Souverain 100 % Local
===============================================================================

🇫🇷 VERSION FRANÇAISE (Forums Linux Mint, Ubuntu-fr, GitHub)
-------------------------------------------------------------------------------
Bonjour à tous !

En 6 jours de développement intensif sur un PC portable Toshiba Portégé R830 (Intel Core i3, 8 Go RAM), j'ai conçu, stabilisé et audité Tiffany AI-OS v48.6, un environnement d'assistance vocale et système 100 % local, souverain, sans cloud et ultra-léger pour Linux (Linux Mint / Ubuntu / Debian).

✨ CE QUE FAIT TIFFANY AI-OS v48.6 :
- 🎙️ Oreille Continue & Réveil Vocal Instantané (Vosk FR) :
  Écoute locale sans abonnement. Répond à la voix (« Tiffany », « Tiff », « Hey ») avec 16 secondes d'écoute enchaînée, anti-mise en veille matérielle et correcteur phonétique adaptatif.
- ⚡ Double Cerveau Hybride (< 0,05 s en Bash + IA locale Ollama) :
  • Réflexes instantanés (< 0,05 s) : 39 boutons graphiques et 28 outils terminal (volume, luminosité, mode froid/boost, purge RAM/ZRAM, recherche de fichiers, capture d'écran, coffre-fort chiffré AES-256) exécutés sans solliciter le processeur.
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
Dépôt GitHub officiel : https://github.com
Logithèque Snap Store : snap install tiffany-ai-os --classic


===============================================================================
🇬🇧 ENGLISH VERSION (Reddit r/linuxmint, r/opensource, r/LocalLLaMA)
===============================================================================
# 🌹 Tiffany AI-OS v48.6 — 100% Local, Hybrid & Self-Evolving Voice OS for Linux

Hey everyone!

In just **6 days of intensive development** on a modest **Toshiba Portégé R830 laptop (Intel Core i3, 8 GB RAM)**, I built, stress-tested, and audited **Tiffany AI-OS v48.6** — a 100% local, privacy-first, zero-cloud voice assistant and system orchestrator for Linux (Linux Mint / Ubuntu / Debian).

### ✨ What Tiffany AI-OS v48.6 Does:
- **🎙️ Continuous Listening & Instant Voice Wake-Up (Vosk):**
  Completely offline voice recognition with zero subscriptions. Wakes up to *"Tiffany"*, *"Tiff"*, or *"Hey"* with 16 seconds of chained follow-up listening, hardware power-save prevention, and an adaptive phonetic corrector.
- **⚡ Hybrid Dual-Brain Architecture (< 0.05s Bash Reflexes + Local Ollama LLMs):**
  - **Instant Reflex Layer (< 0.05s):** 39 GUI buttons and 28 CLI tools (volume, brightness, thermal cold/boost modes, RAM/ZRAM purge, fuzzy file search, screenshots, AES-256 encrypted vault) executed in pure Bash with near-zero CPU load.
  - **Local Neural Brains (Ollama):** Lightweight `tiffany-flash` (397 MB) kept warm in RAM for natural conversation, backed on demand by `qwen2.5:1.5b` and `qwen2.5-coder:1.5b`.
- **🛡️ Thermal Watchdog & Hardware Health:**
  Background `systemd` thermal sentinel automatically throttling CPU governors under heavy load, SMART drive health monitoring, and automatic translation of `journalctl` system errors.
- **📄 Instant PDF Learning, Web-IA & Sandbox Dojo:**
  - Extracts, summarizes, and memorizes any PDF document in 2 seconds.
  - Browserless web research (`Web-IA`) generating structured Markdown dossiers on your Desktop, plus an autonomous sandbox (`Dojo`) to test and learn new shell commands safely.
  - Full GUI Memory Logbook (`Yad`/`Zenity`) to view, add, edit, or delete stored facts in two clicks.
- **⏰ Voice & GUI Task Scheduler:**
  Schedule delayed commands naturally (*"stop radio in 20 minutes"*, *"clean RAM at 23:30"*) or manage them via the graphical scheduler.

### 🔗 Source Code & Quick Install:
- **Official GitHub Repository:** https://github.com
- **Snap Store:** `sudo snap install tiffany-ai-os --classic`

```bash
git clone https://github.com.git ~/tiffany
cd ~/tiffany && chmod +x install.sh && ./install.sh
```

Feedback, stars, and forks are warmly welcome!
===============================================================================
