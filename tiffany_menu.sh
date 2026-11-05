#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_menu.sh (Version 14.6 - VERSION FINALE DE PRODUCTION)
# 🛡️ RÔLE   : Menu Zenity Complet - Distinction Stricte Radios / Musique Locale
# ==============================================================================
ROOT_DIR="$HOME/tiffany"

while true; do
    CHOIX=$(zenity --list \
        --title="Panneau de Contrôle Tiffany v14.6" \
        --column="Action" --column="Description" \
        --width=580 --height=550 \
        "🌹 Parler à Tiffany" "Ouvrir l'invite de discussion historique dans un terminal" \
        "📊 Diagnostic CPU" "Vérifier la température, la fréquence et le Top processus" \
        "🧠 Check-up RAM (Top)" "Afficher les 5 applications qui saturent la mémoire vive" \
        "❄️ Activer Mode Froid" "Brider le processeur pour refroidir le Toshiba" \
        "⚡ Activer Mode Boost" "Redonner la pleine puissance d'origine au CPU" \
        "🛡️ Watchdog ON" "Lancer la sentinelle thermique autonome" \
        "⚠️ Watchdog OFF" "Arrêter la surveillance automatique" \
        "🧼 Vider la Corbeille" "Purger instantanément tous les fichiers de la poubelle" \
        "🧹 Nettoyer Système" "Supprimer les résidus système et vieux paquets APT" \
        "📡 État Réseau" "Vérifier le Wi-Fi, le signal et l'IP locale" \
        "🌙 Mode Filtre de Nuit" "Activer le filtre anti-lumière bleue chaud" \
        "☀️ Mode Normal (Jour)" "Désactiver le filtre écran et restaurer la clarté" \
        "🔊 Couper/Activer Son" "Bascule immédiate de l'état muet (Mute)" \
        "📻 Allumer la Radio" "Lancer ton flux radio favori directement dans Rhythmbox" \
        "🤫 Couper la Radio" "Arrêt instantané du lecteur Rhythmbox" \
        "🎵 Allumer Rhythmbox" "Ouvrir Rhythmbox et forcer la lecture de la bibliothèque locale" \
        "⏸️ Play/Pause Rhythmbox" "Mettre en pause ou relancer la lecture de Rhythmbox" \
        "💤 Éteindre le Toshiba" "Lancer le rapport diary_agent et éteindre proprement le PC" \
        "❌ Quitter" "Fermer le menu" 2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$CHOIX" ] || [[ "$CHOIX" == *"Quitter"* ]]; then
        break
    fi

    case "$CHOIX" in
        *"Parler à Tiffany"*)
            gnome-terminal -- bash -c "~/tiffany/tiffany_core.sh"
            break
            ;;
        *"Diagnostic CPU"*)
            gnome-terminal --title="📊 Fluctuations CPU en Temps Réel" -- bash -c "while true; do clear; ~/tiffany/tiffany_utilitaire.sh 'etat_cpu'; sleep 2; done"
            ;;
        *"Check-up RAM"*)
            gnome-terminal --title="🧠 Fluctuations RAM en Temps Réel" -- bash -c "while true; do clear; ~/tiffany/tiffany_utilitaire.sh 'processus_ram'; sleep 2; done"
            ;;
        *"Activer Mode Froid"*)
            ~/tiffany/tiffany_utilitaire.sh "refroidissement" "froid"
            zenity --info --text="📉 Mode Froid appliqué." --timeout=2 2>/dev/null
            ;;
        *"Activer Mode Boost"*)
            ~/tiffany/tiffany_utilitaire.sh "refroidissement" "chaud"
            zenity --info --text="🚀 Mode Boost appliqué." --timeout=2 2>/dev/null
            ;;
        *"Watchdog ON"*)
            pkill -f tiffany_watchdog.sh >/dev/null 2>&1
            pkill -f thermal_watchdog.sh >/dev/null 2>&1
            ~/tiffany/thermal_watchdog.sh >/dev/null 2>&1 &
            zenity --info --text="🛡️ Sentinelle active." --timeout=2 2>/dev/null
            ;;
        *"Watchdog OFF"*)
            pkill -f tiffany_watchdog.sh >/dev/null 2>&1
            pkill -f thermal_watchdog.sh >/dev/null 2>&1
            zenity --info --text="⚠️ Sentinelle désactivée." --timeout=2 2>/dev/null
            ;;
        *"Vider la Corbeille"*)
            ~/tiffany/tiffany_utilitaire.sh "corbeille"
            zenity --info --text="🧼 Poubelle purgée !" --timeout=2 2>/dev/null
            ;;
        *"Nettoyer Système"*)
            gnome-terminal -- bash -c "~/tiffany/tiffany_utilitaire.sh 'nettoie_systeme'; echo -e '\n[Appuie sur Entrée pour fermer]'; read"
            ;;
        *"État Réseau"*)
            gnome-terminal -- bash -c "~/tiffany/tiffany_utilitaire.sh 'reseau'; echo -e '\n[Appuie sur Entrée pour fermer]'; read"
            ;;
        *"Filtre de Nuit"*)
            ~/tiffany/tiffany_utilitaire.sh "filtre" "nuit"
            ;;
        *"Mode Normal"*)
            ~/tiffany/tiffany_utilitaire.sh "filtre" "jour"
            ;;
        *"Couper/Activer Son"*)
            ~/tiffany/tiffany_utilitaire.sh "audio" "toggle"
            ;;
        *"Allumer la Radio"*)
            STATION=$(zenity --list \
                --title="Sources Radio Rhythmbox - Choix du Créateur" \
                --column="Radio" --column="Flux Source" \
                --width=520 --height=280 \
                "🎵 RDK Radio djiido" "http://radiodjiido.nc:8004" \
                "🎶 Radio Paradise" "http://stream-dc1.radioparadise.com/rp_192m.ogg" \
                "⚡ KINK Radio" "http://playerservices.streamtheworld.com/api/livestream-redirect/KINK.mp3" 2>/dev/null)
            
            if [ $? -eq 0 ] && [ -n "$STATION" ]; then
                if ! pgrep -x "rhythmbox" >/dev/null; then
                    rhythmbox >/dev/null 2>&1 &
                    sleep 4
                fi
                case "$STATION" in
                    *"djiido"*)  URL_FLUX="http://radiodjiido.nc:8004" ;;
                    *"Paradise"*) URL_FLUX="http://stream-dc1.radioparadise.com/rp_192m.ogg" ;;
                    *"KINK"*)     URL_FLUX="http://playerservices.streamtheworld.com/api/livestream-redirect/KINK.mp3" ;;
                esac
                rhythmbox-client --play-uri="$URL_FLUX" >/dev/null 2>&1
                rhythmbox-client --play >/dev/null 2>&1
            fi
            ;;
        *"Couper la Radio"*)
            rhythmbox-client --pause >/dev/null 2>&1
            ;;
                             *"Allumer Rhythmbox"*)
           # 1. Coupure immédiate de tous les lecteurs vidéo ou films en cours
           pkill -9 -x "mpv" >/dev/null 2>&1
           pkill -9 -x "vlc" >/dev/null 2>&1

           if ! pgrep -x "rhythmbox" >/dev/null; then
               rhythmbox >/dev/null 2>&1 &
               sleep 4
           else
               # On coupe la radio et on vide la file d'attente pour effacer le lien internet
               rhythmbox-client --stop >/dev/null 2>&1
               rhythmbox-client --clear-queue >/dev/null 2>&1
           fi

           # 2. On active de force le mode aléatoire (Shuffle)
           rhythmbox-client --shuffle >/dev/null 2>&1

           # 3. On injecte l'intégralité du dossier Musique de l'ordinateur dans le lecteur
           rhythmbox-client --enqueue "$HOME/Musique" >/dev/null 2>&1

           # 4. On force le démarrage immédiat et automatique de la musique
           rhythmbox-client --play >/dev/null 2>&1
           ;;       
        *"Play/Pause Rhythmbox"*)
           # Commande universelle de bascule Play/Pause pour Rhythmbox
           rhythmbox-client --no-start --play-pause >/dev/null 2>&1 || rhythmbox-client --play >/dev/null 2>&1
           ;;



        *"Éteindre le Toshiba"*)
            pkill -f tiffany_watchdog.sh >/dev/null 2>&1
            pkill -f thermal_watchdog.sh >/dev/null 2>&1
            rhythmbox-client --quit >/dev/null 2>&1
            if [ -f "$ROOT_DIR/agents/diary_agent.py" ]; then
                python3 "$ROOT_DIR/agents/diary_agent.py" >/dev/null 2>&1
            fi
            systemctl poweroff || poweroff
            break
            ;;
    esac
    sleep 0.1
done


