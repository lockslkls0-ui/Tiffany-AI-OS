# 📘 RAPPORT INTÉGRAL : TIFFANY AI-OS (V47.4)
**Créateur :** lockslkls | **Dépôt :** https://github.com

## 🌟 1. GENÈSE & MATÉRIEL
Projet 100% local conçu en quelques jours sans formation préalable. Calibré pour Intel Core i3-2350M sans GPU grâce au bouclier thermique (cpulimit, Mode Froid/Boost, Watchdog) et à la lecture directe des capteurs noyau (/sys/class/).

## 🧠 2. ARCHITECTURE HYBRIDE & SÉCURITÉ
- **Niveau 1 (< 0,05s) :** Réflexes Bash purs (ca va, capteurs, surnom dynamique).
- **Niveau 2 (397 Mo) :** tiffany-flash préchauffé pour le dialogue fluide.
- **Niveau 3 & 4 (986 Mo) :** qwen2.5:1.5b (Web-IA, souvenirs) et qwen2.5-coder:1.5b (Dojo, Docteur).
- **Coffre-fort & Panneau :** Chiffrement 7z (-mhe=on) + verrou noyau (chattr +i) et 29 boutons graphiques.
