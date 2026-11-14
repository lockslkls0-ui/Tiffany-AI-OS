# 🌹 Tiffany AI-OS v48.6

**Tiffany AI-OS** est un système d'assistance vocale, hybride et autonome **100 % local** pour Linux (Linux Mint / Ubuntu / Debian), conçu et assemblé en **6 jours** pour offrir une fluidité extrême même sur des ordinateurs portables modestes (Intel Core i3 / 8 Go RAM).

## ✨ Fonctionnalités Principales
- **🎙️ Oreille Continue & Réveil Vocal Instantané (Vosk FR) :** Écoute locale sans cloud avec 16 secondes d'écoute enchaînée, anti-mise en veille matérielle et correcteur phonétique adaptatif.
- **⚡ Architecture Hybride (< 0,05 s en Bash + Cerveaux Ollama) :**
  - **Réflexes directs :** 39 boutons graphiques et 28 outils terminal exécutés instantanément sans solliciter le processeur.
  - **IA locale :** `tiffany-flash` préchargé en RAM pour une discussion fluide, soutenu par `qwen2.5:1.5b` et `qwen2.5-coder:1.5b`.
- **🛡️ Sentinelle Thermique & Santé Matérielle :** Régulation automatique de fréquence CPU (`systemd`), compression mémoire ZRAM (`lz4`), lecture SMART du disque et traduction des logs système en français.
- **📄 Apprentissage Éclair PDF, Web-IA & Dojo :** Résume et mémorise instantanément des fichiers PDF, effectue des recherches encyclopédiques sur le web et forge ses propres commandes en bac à sable.
- **⏰ Planificateur & Réveils Vocaux :** Programmation d'actions différées (*« coupe la radio dans 20 minutes »*) ou via l'interface graphique.

## 🚀 Installation Rapide
```bash
git clone https://github.com ~/tiffany
cd ~/tiffany && chmod +x install.sh && ./install.sh
```
