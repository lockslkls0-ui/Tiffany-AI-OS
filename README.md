===============================================================================
🌹 TIFFANY AI-OS v48.6 — Assistant Vocal, Hybride & Auto-Évolutif 100 % Local
===============================================================================

Bonjour à tous !

En 6 jours de développement intensif sur un PC portable Toshiba Portégé R830 (Intel Core i3, 8 Go RAM), j'ai conçu, stabilisé et audité Tiffany AI-OS v48.6, un environnement d'assistance vocale et système 100 % local, souverain, sans cloud et ultra-léger pour Linux (Linux Mint / Ubuntu / Debian).

✨ CE QUE FAIT TIFFANY AI-OS v48.6 :
- 🎙️ Oreille Continue & Réveil Vocal Instantané (Vosk FR) :
  Écoute locale sans abonnement. Répond à la voix (« Tiffany », « Tiff », « Hey ») avec 16 secondes d'écoute enchaînée, anti-mise en veille matérielle et correcteur phonétique adaptatif.
- ⚡ Double Cerveau Hybride (< 0,05 s en Bash + IA locale Ollama) :
  • Réflexes instantanés (< 0,05 s) : 39 boutons graphiques et 28 outils terminal (gestion du volume, luminosité, mode froid/boost, purge RAM/ZRAM, recherche de fichiers, capture d'écran, coffre-fort chiffré AES-256) exécutés sans solliciter le processeur.
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

git clone https://github.com.git ~/tiffany
cd ~/tiffany && chmod +x install.sh && ./install.sh

N'hésitez pas à tester, forker ou me faire vos retours !
===============================================================================
