#!/usr/bin/env bash
# TERM_KEY: web
# TERM_DESC: Aspirer et apprendre une page web sur un sujet
# TERM_ICON: 🌍

REQUETE="$*"
SUJET=$(echo "$REQUETE" | sed -E 's/^web//I' | xargs)
CTX_FILE="$HOME/tiffany/memory/contexte_matrice.txt"

if [ -z "$SUJET" ]; then
    echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Quel sujet dois-je aspirer et apprendre sur le web, mon ange ?\n"
    exit 0
fi

echo -e "\n\033[1;36m🌍 [Radar Web] Recherche du meilleur lien pour : '$SUJET'...\033[0m"
(espeak-ng -v fr+f5 -s 140 -p 85 "Je cherche une page sur le web pour l'apprendre chéri." >/dev/null 2>&1) &

URL_CIBLE=$(python3 -c "
from duckduckgo_search import DDGS
try:
    res = list(DDGS().text('$SUJET', region='fr-fr', max_results=1))
    print(res[0]['href'] if res else '')
except Exception:
    print('')
" 2>/dev/null)

if [ -z "$URL_CIBLE" ]; then
    echo -e "\033[1;31m❌ Aucun lien web trouvé pour '$SUJET' (vérifie la connexion).\033[0m\n"
    exit 0
fi

echo -e "\033[1;33m📥 Aspiration directe de la page :\033[0m $URL_CIBLE"

# Lecture et nettoyage HTML 100% local en Python (Sans passer par Jina)
TEXTE_PAGE=$(python3 -c "
import urllib.request, re, html, ssl
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
req = urllib.request.Request('$URL_CIBLE', headers={'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64)'})
try:
    raw = urllib.request.urlopen(req, timeout=15, context=ctx).read().decode('utf-8', errors='ignore')
    raw = re.sub(r'<(script|style|nav|header|footer)[^>]*>.*?</\1>', ' ', raw, flags=re.S|re.I)
    txt = re.sub(r'<[^>]+>', ' ', raw)
    txt = re.sub(r'\s+', ' ', html.unescape(txt)).strip()
    print(txt[:1600])
except Exception:
    print('')
" 2>/dev/null)

if [ -z "$TEXTE_PAGE" ] || [ ${#TEXTE_PAGE} -lt 30 ]; then
    echo -e "\033[1;31m❌ Impossible de lire le contenu de cette page.\033[0m\n"
    exit 0
fi

echo -e "\033[1;34m🧠 [Gros Cerveau 1.5b] Apprentissage et synthèse en cours...\033[0m"
(
    PROMPT="Tu es Tiffany, l'assistante virtuelle amoureuse de ton Créateur. Tu viens de lire cette page web concernant '$SUJET' : [$TEXTE_PAGE]. Résume l'essentiel (ingrédients, étapes ou faits clés) de façon claire et utile en français (60 mots max)."
    SYNTHESE=$(nice -n 19 timeout 180 ollama run qwen2.5:1.5b "$PROMPT" 2>/dev/null)
    if [ -n "$SYNTHESE" ]; then
        echo -e "\n\033[1;35m🌹 Tiffany (Appris du Web) :\033[0m $SYNTHESE\n"
        (espeak-ng -v fr+f5 -s 140 -p 85 "$(echo "$SYNTHESE" | sed 's/\*//g')" >/dev/null 2>&1) &
        echo "Connaissance Web ($SUJET) : $SYNTHESE" >> "$CTX_FILE"
    fi
) &

