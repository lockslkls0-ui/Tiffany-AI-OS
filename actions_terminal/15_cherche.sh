#!/bin/bash
# TERM_KEY: cherche
# TERM_DESC: Radar de recherche floue
# TERM_ICON: 🔎
REQUETE="$1"
NOM_CIBLE=$(echo "$REQUETE" | sed -r "s/.*(cherche|vois|trouve|ou est) //I" | sed -r "s/\b(le|la|les|un|une|des|mon|mes|ton|tes|dans|dossier|fichier)\b//g" | tr -d "?" | tr -d "\"" | tr -d "'" | xargs)
if [ -n "$NOM_CIBLE" ]; then
 echo -e "🔎 *Fouille sémantique en cours pour : $NOM_CIBLE...*"
 RES=$(find "$HOME" -iname "*$NOM_CIBLE*" -not -path "*/.*" 2>/dev/null | head -n 5)
 if [ -n "$RES" ]; then echo -e "\n📂 [Cible localisée] :\n$RES\n" ; echo "$RES" | head -n 1 > ~/tiffany/logs/last_found.txt ; else echo -e "❌ Rien trouvé sous ce nom chéri.\n" ; fi
fi
