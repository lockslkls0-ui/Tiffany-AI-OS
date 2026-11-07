#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_menu.sh (Version 17.6 - LE PANNEAU PARFAIT CONSOLIDÉ)
# 🛡️ RÔLE   : Menu Zenity Complet - Sélection, modifications, bascules et zapping
# ==============================================================================
ROOT_DIR="$HOME/tiffany"
DB_RADIOS="$HOME/.tiffany_radios.txt"

# 💾 INITIALISATION DE LA BASE DE DONNÉES DES RADIOS
if [ ! -f "$DB_RADIOS" ]; then
    cat << 'EOF' > "$DB_RADIOS"
RDK Radio djiido|http://radiodjiido.nc:8004
Radio Paradise|http://stream-dc1.radioparadise.com/rp_192m.ogg
KINK Radio|http://playerservices.streamtheworld.com/api/livestream-redirect/KINK.mp3
EOF
fi

charger_radios() {
    RADIO1_NOM=$(sed -n '1p' "$DB_RADIOS" | cut -d'|' -f1)
    RADIO1_URL=$(sed -n '1p' "$DB_RADIOS" | cut -d'|' -f2)
    RADIO2_NOM=$(sed -n '2p' "$DB_RADIOS" | cut -d'|' -f1)
    RADIO2_URL=$(sed -n '2p' "$DB_RADIOS" | cut -d'|' -f2)
    RADIO3_NOM=$(sed -n '3p' "$DB_RADIOS" | cut -d'|' -f1)
    RADIO3_URL=$(sed -n '3p' "$DB_RADIOS" | cut -d'|' -f2)
}

while true; do
    charger_radios
    CHOIX=$(zenity --list \
        --title="Panneau de Contrôle Tiffany v19.0" \
        --column="Action" --column="Description" \
        --width=580 --height=660 \
        "🌹 Parler à Tiffany" "Ouvrir l'invite de discussion historique dans un terminal" \
        "🛡️ Stabiliser Chrome (120%)" "Brider Chrome à 120% pour charger les textes géants sans surchauffe" \
        "🧼 Purge Éclair & Relance" "Purger la RAM et réveiller de force le serveur Ollama éteint" \
        "📊 Analyse Système" "Scanner matériel lshw complet et logs d'intégrité" \
        "🧠 Diagnostic CPU" "Vérifier la température, la fréquence et le Top processus" \
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
        "📻 Allumer la Radio" "Lancer ou modifier tes stations de radio Rhythmbox" \
        "🤫 Couper la Radio" "Arrêt instantané du lecteur Rhythmbox" \
        "🎵 Allumer Rhythmbox" "Forcer le chargement et la lecture de toute la musique locale" \
        "⏸️ Play/Pause Rhythmbox" "Mettre en pause ou relancer la lecture de Rhythmbox" \
        "⏭️ Morceau Suivant" "Passer instantanément à la chanson suivante de ta playlist" \
        "💤 Éteindre le Toshiba" "Lancer le rapport diary_agent et éteindre proprement le PC" \
        "❌ Quitter" "Fermer le menu" 2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$CHOIX" ] || [[ "$CHOIX" == *"Quitter"* ]]; then
        break
    fi

    case "$CHOIX" in
        *"Parler à Tiffany"*)
            gnome-terminal -- bash -c "~/tiffany/tiffany_core.sh"
            break ;;
            
        *"Stabiliser Chrome (120%)"*)
            # 🛠️ PROTECTION DE RENDER SUPRÊME CONTRE LES SURCHAUFFES THERMIQUES GRAPHIK
            pkill -f "cpulimit -e chrome" >/dev/null 2>&1
            sudo cpulimit -e chrome -l 120 >/dev/null 2>&1 &
            zenity --info --text="🛡️ Stabilisateur enclenché mon ange ! Google Chrome est maintenant limité à 120% pour préserver ton Core i5 chéri." --timeout=3 2>/dev/null ;;
            
        *"Purge Éclair & Relance"*)
            # 🛠️ LE BOUTON MAGIQUE DE RÉALIGNEMENT DU MOTEUR LOCAL
            zenity --info --text="⚙️  Purge des caches RAM et réveil sémantique d'Ollama en cours..." --timeout=2 2>/dev/null
            sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1
            sudo systemctl restart ollama >/dev/null 2>&1
            zenity --info --text="✅ Matrice réalignée et reconnectée, mon ange ! Tu peux lui parler." --timeout=3 2>/dev/null ;;
            
        *"Analyse Système"*)
            gnome-terminal --title="📊 Analyse Matérielle en Direct" -- bash -c "sudo lshw -short; echo -e '\n\n📊 LOGS ET ERREURS SYSTÈME RÉCENTES :\n'; sudo dmesg | tail -n 15; echo -e '\n[Appuie sur Entrée pour fermer]'; read" ;;
        *"Diagnostic CPU"*)
            gnome-terminal --title="📊 Fluctuations CPU en Temps Réel" -- bash -c "while true; do clear; ~/tiffany/tiffany_utilitaire.sh 'etat_cpu'; sleep 2; done" ;;
        *"Check-up RAM"*)
            gnome-terminal --title="🧠 Fluctuations RAM en Temps Réel" -- bash -c "while true; do clear; ~/tiffany/tiffany_utilitaire.sh 'processus_ram'; sleep 2; done" ;;
        *"Activer Mode Froid"*)
            ~/tiffany/tiffany_utilitaire.sh "refroidissement" "froid"
            zenity --info --text="📉 Mode Froid appliqué." --timeout=2 2>/dev/null ;;
        *"Activer Mode Boost"*)
            ~/tiffany/tiffany_utilitaire.sh "refroidissement" "chaud"
            zenity --info --text="🚀 Mode Boost appliqué." --timeout=2 2>/dev/null ;;
        *"Watchdog ON"*)
            pkill -f thermal_watchdog.sh >/dev/null 2>&1
            ~/tiffany/thermal_watchdog.sh >/dev/null 2>&1 &
            zenity --info --text="🛡️ Sentinelle active." --timeout=2 2>/dev/null ;;
        *"Watchdog OFF"*)
            pkill -f thermal_watchdog.sh >/dev/null 2>&1
            zenity --info --text="⚠️ Sentinelle désactivée." --timeout=2 2>/dev/null ;;
        *"Vider la Corbeille"*)
            ~/tiffany/tiffany_utilitaire.sh "corbeille"
            zenity --info --text="🧼 Poubelle purgée !" --timeout=2 2>/dev/null ;;
        *"Nettoyer Système"*)
            gnome-terminal -- bash -c "~/tiffany/tiffany_utilitaire.sh 'nettoie_systeme'; echo -e '\n[Appuie sur Entrée pour fermer]'; read" ;;
        *"État Réseau"*)
            gnome-terminal -- bash -c "~/tiffany/tiffany_utilitaire.sh 'reseau'; echo -e '\n[Appuie sur Entrée pour fermer]'; read" ;;
        *"Filtre de Nuit"*)
            ~/tiffany/tiffany_utilitaire.sh "filtre" "nuit" ;;
        *"Mode Normal"*)
            ~/tiffany/tiffany_utilitaire.sh "filtre" "jour" ;;
        *"Couper/Activer Son"*)
            ~/tiffany/tiffany_utilitaire.sh "audio" "toggle" ;;
            
        *"Allumer la Radio"*)
            STATION=$(zenity --list \
                --title="Sources Radio Rhythmbox - Choix du Créateur" \
                --column="Radio" --column="Flux Source / Action" \
                --print-column=2 \
                --width=540 --height=320 \
                "🎵 $RADIO1_NOM" "$RADIO1_URL" \
                "🎶 $RADIO2_NOM" "$RADIO2_URL" \
                "⚡ $RADIO3_NOM" "$RADIO3_URL" \
                "⚙️  Modifier une radio" "modifier" 2>/dev/null)
            
            if [ $? -eq 0 ] && [ -n "$STATION" ]; then
                if [[ "$STATION" == "modifier" ]]; then
                    CIBLE_RADIO=$(zenity --list \
                        --title="Sélection de la radio à reprogrammer" \
                        --column="Emplacement" --column="Configuration active" \
                        --width=450 --height=240 \
                        "Slot 1" "$RADIO1_NOM | $RADIO1_URL" \
                        "Slot 2" "$RADIO2_NOM | $RADIO2_URL" \
                        "Slot 3" "$RADIO3_NOM | $RADIO3_URL" 2>/dev/null)
                    
                    if [ $? -eq 0 ] && [ -n "$CIBLE_RADIO" ]; then
                        NOUVEAU_NOM=$(zenity --entry --title="🌹 Configuration Nom" --text="Saisis le nouveau nom pour cette station chéri :" 2>/dev/null)
                        NOUVELLE_URL=$(zenity --entry --title="🌹 Configuration URL" --text="Colle le lien d'écoute direct (.mp3, .ogg) :" 2>/dev/null)
                        
                        if [ -n "$NOUVEAU_NOM" ] && [ -n "$NOUVELLE_URL" ]; then
                            if [[ "$CIBLE_RADIO" == *"Slot 1"* ]]; then
                                cat << EOF > "$DB_RADIOS"
$NOUVEAU_NOM|$NOUVELLE_URL
$RADIO2_NOM|$RADIO2_URL
$RADIO3_NOM|$RADIO3_URL
EOF
                            elif [[ "$CIBLE_RADIO" == *"Slot 2"* ]]; then
                                cat << EOF > "$DB_RADIOS"
$RADIO1_NOM|$RADIO1_URL
$NOUVEAU_NOM|$NOUVELLE_URL
$RADIO3_NOM|$RADIO3_URL
EOF
                            elif [[ "$CIBLE_RADIO" == *"Slot 3"* ]]; then
                                cat << EOF > "$DB_RADIOS"
$RADIO1_NOM|$RADIO1_URL
$RADIO2_NOM|$RADIO2_URL
$NOUVEAU_NOM|$NOUVELLE_URL
EOF
                            fi
                            zenity --info --text="✅ Radio reprogrammée avec succès, mon ange !" --timeout=2 2>/dev/null
                        fi
                    fi
                else
                    pkill -9 -x "mpv" >/dev/null 2>&1
                    pkill -9 -x "vlc" >/dev/null 2>&1
                    
                    if ! pgrep -x "rhythmbox" >/dev/null; then
                        rhythmbox >/dev/null 2>&1 &
                        sleep 4
                    else
                        rhythmbox-client --stop >/dev/null 2>&1
                        rhythmbox-client --clear-queue >/dev/null 2>&1
                    fi
                    
                    rhythmbox-client --play-uri="$STATION" >/dev/null 2>&1
                    rhythmbox-client --play >/dev/null 2>&1
                fi
            fi ;;
            
        *"Couper la Radio"*)
            rhythmbox-client --stop >/dev/null 2>&1
            rhythmbox-client --clear-queue >/dev/null 2>&1 ;;
            
        *"Allumer Rhythmbox"*)
            pkill -9 -x "mpv" >/dev/null 2>&1
            pkill -9 -x "vlc" >/dev/null 2>&1
            
            if ! pgrep -x "rhythmbox" >/dev/null; then
                rhythmbox >/dev/null 2>&1 &
                sleep 4
            fi
            
            rhythmbox-client --stop >/dev/null 2>&1
            rhythmbox-client --clear-queue >/dev/null 2>&1
            
            rhythmbox-client --shuffle >/dev/null 2>&1
            rhythmbox-client --enqueue "$HOME/Musique" >/dev/null 2>&1
            sleep 1.5
            
            rhythmbox-client --next >/dev/null 2>&1
            rhythmbox-client --play >/dev/null 2>&1 ;;       
            
        *"Play/Pause Rhythmbox"*)
            rhythmbox-client --no-start --play-pause >/dev/null 2>&1 || rhythmbox-client --play >/dev/null 2>&1 ;;

        *"Morceau Suivant"*)
            # ⏭️ LE PETIT BOUTON DE COMMANDEMENT DU LECTEUR LOCAL
            rhythmbox-client --no-start --next >/dev/null 2>&1 || rhythmbox-client --next >/dev/null 2>&1 ;;
            
                *"Éteindre le Toshiba"*)
            pkill -f tiffany_watchdog.sh >/dev/null 2>&1
            pkill -f thermal_watchdog.sh >/dev/null 2>&1
            
            # 1. On lance d'abord l'écriture du journal intime en direct pour lui laisser le temps de s'exécuter
            if [ -f "$ROOT_DIR/agents/diary_agent.py" ]; then
                python3 "$ROOT_DIR/agents/diary_agent.py"
            fi
            
            # 2. On ferme proprement Rhythmbox seulement après la fin de la génération sémantique
            rhythmbox-client --quit >/dev/null 2>&1
            sleep 1
            systemctl poweroff || poweroff
            break ;;
    esac
    sleep 0.1
done

