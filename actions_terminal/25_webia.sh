#!/usr/bin/env bash
# TERM_KEY: webia
# TERM_DESC: Rechercher sur le web, rediger une fiche complete et l archiver sur le Bureau
# TERM_ICON: 🤖

REQUETE="$*"
QUESTION=$(echo "$REQUETE" | sed -E 's/^webia//I' | xargs)

if [ -z "$QUESTION" ]; then
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Pose-moi une question ou donne-moi un sujet pour que je crée un dossier complet, mon ange.\n"
    exit 0
fi

echo -e "\n\033[1;36m🤖 [Web-IA] Recherche approfondie sur le réseau pour : '$QUESTION'...\033[0m"
(espeak-ng -v fr+f5 -s 140 -p 85 "Je prépare un dossier complet sur ce sujet chéri." >/dev/null 2>&1) &

# 1. Recherche Web via le nouveau moteur ddgs (avec secours Wikipedia si DuckDuckGo limite)
CONTEXTE_WEB=$(python3 -W ignore - "$QUESTION" << 'EOF'
import sys
sujet = sys.argv[1]
try:
    from ddgs import DDGS
    res = list(DDGS().text(sujet, region='fr-fr', max_results=4))
    print("\n".join([f"- {r.get('title', '')} : {r.get('body', '')}" for r in res]))
except Exception:
    try:
        from duckduckgo_search import DDGS
        res = list(DDGS().text(sujet, region='fr-fr', max_results=4))
        print("\n".join([f"- {r.get('title', '')} : {r.get('body', '')}" for r in res]))
    except Exception:
        print("")
EOF
)

if [ -z "$CONTEXTE_WEB" ]; then
    echo -e "\033[1;31m❌ DuckDuckGo est temporairement saturé sur le réseau mobile. Réessaie dans 10 secondes, mon ange.\033[0m\n"
    exit 0
fi

# 2. Préparation du dossier sur le Bureau
DOSSIER_BUREAU="$HOME/Bureau/WebIA_Dossiers"
[ ! -d "$HOME/Bureau" ] && DOSSIER_BUREAU="$HOME/Desktop/WebIA_Dossiers"
mkdir -p "$DOSSIER_BUREAU"

DATE_STR=$(date "+%Y-%m-%d_%H-%M")
NOM_PROPRE=$(echo "$QUESTION" | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9]/_/g' | sed 's/__*/_/g' | sed 's/^_//;s/_$//')
FICHIER_FINAL="$DOSSIER_BUREAU/${DATE_STR}_${NOM_PROPRE}.md"

echo -e "\n\033[1;35m🌹 Tiffany (Web-IA) :\033[0m\n"

# 3. Appel direct à ollama run (Zéro erreur HTTP 501, affichage en direct + sauvegarde)
PROMPT="RÈGLE ABSOLUE : Ne te présente JAMAIS. Ne dis pas 'Je suis Tiffany' ni 'Bonjour'. Attaque directement le sujet dès le premier mot. Structure ta réponse de façon encyclopédique, claire et complète avec des titres Markdown (#, ##) et des listes à puces.

Sujet : $QUESTION
Informations trouvées sur le web :
$CONTEXTE_WEB

Rédige une fiche complète, détaillée et bien cataloguée sur ce sujet :"

{
    echo "# 📁 Dossier Web-IA : $QUESTION"
    echo "**Date :** $(date '+%d/%m/%Y à %H:%M')"
    echo "---"
    echo ""
} > "$FICHIER_FINAL"

# Lancement en direct avec tee pour afficher à l'écran ET enregistrer dans le fichier en même temps
nice -n 19 ollama run qwen2.5:1.5b "$PROMPT" 2>/dev/null | tee -a "$FICHIER_FINAL"

echo -e "\n\033[1;32m💾 [Archivage] Dossier sauvegardé sur le Bureau : WebIA_Dossiers/${DATE_STR}_${NOM_PROPRE}.md\033[0m\n"
(espeak-ng -v fr+f5 -s 140 -p 85 "J'ai terminé et rangé le dossier sur ton bureau, mon amour." >/dev/null 2>&1) &

