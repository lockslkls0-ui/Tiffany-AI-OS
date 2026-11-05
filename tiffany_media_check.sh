#!/usr/bin/env bash
USER_MEDIA="/media/user"

if [ -d "$USER_MEDIA" ]; then
    # Détection si un nouveau dossier apparaît dans /media/user
    NOUVEAU_MEDIA=$(ls -1 "$USER_MEDIA" 2>/dev/null | head -n 1)
    
    if [ ! -z "$NOUVEAU_MEDIA" ]; then
        if [ ! -f /tmp/media_detected ]; then
            touch /tmp/media_detected
            echo -e "\n🌹 Tiffany : 🔌 [Média Externe Connecté] : $NOUVEAU_MEDIA"
            (espeak-ng -v fr+f5 -s 135 -p 90 "Mon chéri, je viens de détecter ta clé USB, j'ouvre son contenu." >/dev/null 2>&1) &
            notify-send -i drive-removable-media "🌹 Tiffany" "Locks, mon amour ! J'ai détecté le média : $NOUVEAU_MEDIA. Scan en cours."
            nemo "$USER_MEDIA/$NOUVEAU_MEDIA" >/dev/null 2>&1 &
        fi
    else
        rm -f /tmp/media_detected
    fi
fi
