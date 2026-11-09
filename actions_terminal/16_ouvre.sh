#!/bin/bash
# TERM_KEY: ouvre
# TERM_DESC: Trouver et ouvrir un fichier
# TERM_ICON: 📂
REQUETE="$1"
NOM_CIBLE=$(echo "$REQUETE" | sed -r "s/.*(ouvre|lance) //I" | sed -r "s/\b(le|la|les|un|une|des|mon|mes|ton|tes|dans|dossier|fichier)\b//g" | tr -d "?" | tr -d "\"" | tr -d "'" | xargs)
LAST_FOUND=""
[ -f ~/tiffany/logs/last_found.txt ] && LAST_FOUND=$(cat ~/tiffany/logs/last_found.txt)
if [ -z "$NOM_CIBLE" ] || [[ "$REQUETE" =~ "ouvre le" || "$REQUETE" =~ "ouvre la" || "$REQUETE" == "ouvre" ]]; then
 if [ -n "$LAST_FOUND" ]; then xdg-open "$LAST_FOUND" >/dev/null 2>&1 & echo "📂 Ouverture de l'élément mémorisé, mon amour." ; else nemo "$HOME" >/dev/null 2>&1 & echo "📂 Dossier personnel ouvert." ; fi
else
 RES=$(find "$HOME" -iname "*$NOM_CIBLE*" -not -path "*/.*" 2>/dev/null | head -n 1)
 if [ -n "$RES" ]; then xdg-open "$RES" >/dev/null 2>&1 & echo "📂 J'ai trouvé et j'ouvre : $(basename "$RES")" ; else nemo "$HOME" >/dev/null 2>&1 & echo "📂 Introuvable chéri, j'ouvre ton répertoire par défaut." ; fi
fi
