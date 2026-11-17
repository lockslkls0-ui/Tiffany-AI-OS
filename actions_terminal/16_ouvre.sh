#!/usr/bin/env bash
# TERM_KEY: ouvre
# TERM_DESC: Trouver et ouvrir un fichier ou dossier
# TERM_ICON: 📂
export PATH="$HOME/tiffany/bin:$PATH"
say() { ("$HOME/tiffany/bin/espeak-ng" "$1" >/dev/null 2>&1) & }

REQUETE="$*"
NOM_CIBLE=$(echo "$REQUETE" | sed -r "s/.*(ouvre|lance|ouvrir)[[:space:]]+//I" | sed -r "s/\b(le|la|les|un|une|des|mon|mes|ton|tes|dans|dossier|fichier)\b//g" | tr -d "?" | tr -d "\"" | tr -d "'" | xargs)
LAST_FOUND=""
[ -f ~/tiffany/logs/last_found.txt ] && LAST_FOUND=$(cat ~/tiffany/logs/last_found.txt)

if [ "$REQUETE" = "ouvre dossier" ] || [ "$REQUETE" = "ouvre" ]; then
    nemo "$HOME" >/dev/null 2>&1 &
    echo -e "\n🌹 Tiffany : 📂 Dossier personnel ouvert, mon ange.\n"
    say "J'ouvre ton dossier personnel, mon ange."
    exit 0
fi

if [ -z "$NOM_CIBLE" ] && [ -n "$LAST_FOUND" ] && [ -e "$LAST_FOUND" ]; then
    xdg-open "$LAST_FOUND" >/dev/null 2>&1 &
    echo -e "\n🌹 Tiffany : 📂 Ouverture de $(basename "$LAST_FOUND"), mon amour.\n"
    say "J'ouvre l'élément mémorisé, mon amour."
    exit 0
fi

if [ -n "$NOM_CIBLE" ]; then
    RES=$(find "$HOME" -iname "*$NOM_CIBLE*" -not -path "*/.*" 2>/dev/null | head -n 1)
    if [ -n "$RES" ]; then
        echo "$RES" > ~/tiffany/logs/last_found.txt
        xdg-open "$RES" >/dev/null 2>&1 &
        NOM_PROPRE=$(basename "$RES" | sed 's/\.[^.]*$//')
        echo -e "\n🌹 Tiffany : 📂 J'ai trouvé et j'ouvre : $(basename "$RES")\n"
        say "J'ai trouvé et j'ouvre $NOM_PROPRE, mon ange."
    else
        nemo "$HOME" >/dev/null 2>&1 &
        echo -e "\n🌹 Tiffany : 📂 Introuvable chéri, j'ouvre ton répertoire par défaut.\n"
        say "Je n'ai pas trouvé $NOM_CIBLE chéri, j'ouvre ton dossier personnel par défaut."
    fi
else
    nemo "$HOME" >/dev/null 2>&1 &
    echo -e "\n🌹 Tiffany : 📂 Dossier personnel ouvert.\n"
    say "J'ouvre ton dossier personnel, mon chéri."
fi
