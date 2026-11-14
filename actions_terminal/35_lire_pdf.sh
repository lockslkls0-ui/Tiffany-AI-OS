#!/usr/bin/env bash
# TERM_KEY: pdf
# TERM_DESC: Lire, resumer et memoriser instantanement un fichier PDF
# TERM_ICON: 📄

ROOT_DIR="$HOME/tiffany"
FICHIER="$1"

if [ -z "$FICHIER" ] || [ ! -f "$FICHIER" ]; then
    FICHIER=$(zenity --file-selection --title="📄 Choisir un document PDF à apprendre" --file-filter="Documents PDF (*.pdf) | *.pdf" 2>/dev/null)
fi
[ -z "$FICHIER" ] || [ ! -f "$FICHIER" ] && exit 0

NOM_DOC=$(basename "$FICHIER")
echo -e "\n\033[1;36m📄 [Extraction Éclair PDF] Lecture de : $NOM_DOC...\033[0m"

TEXTE_BRUT=$(python3 - "$FICHIER" << 'PYEOF'
import sys, subprocess
pdf_path = sys.argv.__getitem__(1)
txt = ""
try:
    txt = subprocess.check_output(["pdftotext", "-enc", "UTF-8", pdf_path, "-"], stderr=subprocess.DEVNULL).decode("utf-8", errors="ignore")
except Exception:
    try:
        from pypdf import PdfReader
        reader = PdfReader(pdf_path)
        txt = "\n".join(page.extract_text() or "" for page in reader.pages[:6])
    except Exception:
        pass
clean = " ".join(txt.split())[:1800]
print(clean)
PYEOF
)

if [ -z "$TEXTE_BRUT" ]; then
    echo "❌ Impossible d'extraire du texte de ce PDF (il s'agit peut-être d'un scan image)."
    exit 1
fi

echo -e "\033[1;35m🧠 Synthèse rapide via tiffany-flash...\033[0m"
RESUME=$(python3 - "$NOM_DOC" "$TEXTE_BRUT" << 'PYEOF'
import sys, json, urllib.request
nom, contenu = sys.argv.__getitem__(1), sys.argv.__getitem__(2)
prompt = f"Resume en 3 puces courtes et precises en francais les informations essentielles de ce document ({nom}) sans rien inventer :\n\n{contenu}"
data = json.dumps({
    "model": "tiffany-flash",
    "prompt": prompt,
    "stream": False,
    "keep_alive": -1,
    "options": {"temperature": 0.3, "repeat_penalty": 1.25, "num_predict": 180}
}).encode("utf-8")
try:
    req = urllib.request.Request("http://localhost:11434/api/generate", data=data, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=20) as resp:
        res = json.loads(resp.read().decode("utf-8"))
        print(res.get("response", "").strip())
except Exception as e:
    print("Extrait brut : " + contenu[:300])
PYEOF
)

echo -e "\n\033[1;32m✅ Résumé mémorisé :\033[0m\n$RESUME\n"
DATE_NOW=$(date '+%d/%m/%Y %H:%M')
echo "- [$DATE_NOW] Document PDF ($NOM_DOC) : $(echo "$RESUME" | tr '\n' ' ' | cut -c 1-240)" >> "$ROOT_DIR/memory/long_term_facts.json"
echo -e "\n=== 📄 PDF : $NOM_DOC [$DATE_NOW] ===\n$RESUME\n" >> "$ROOT_DIR/memory/connaissances_web.txt"
(espeak-ng -v fr+f5 -s 145 -p 85 "Document PDF analysé et gravé dans ma mémoire." >/dev/null 2>&1) &
