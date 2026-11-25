#!/usr/bin/env bash
# TERM_KEY: pdf
# TERM_DESC: Extraire, apprendre et archiver integralement un fichier PDF
# TERM_ICON: 📄

ROOT_DIR="$HOME/tiffany"
[ ! -s "$HOME/.config/tiffany/pro_license_disabled_launch" ] && ("$HOME/tiffany/bin/espeak-ng" "Cette option fait partie de l'édition Pro." >/dev/null 2>&1 &) && zenity --question --title="💎 Option Édition PRO" --text="Cette fonctionnalité avancée nécessite l'Édition PRO.\nVoulez-vous entrer votre clé d'activation maintenant ?" --width=420 2>/dev/null && bash "$HOME/tiffany/plugins/00c_activer_pro.sh" && exit 0

FICHIER="$1"

if [ -z "$FICHIER" ] || [ ! -f "$FICHIER" ]; then
    FICHIER=$(zenity --file-selection --title="📄 Choisir un document PDF à apprendre en entier" --file-filter="Documents PDF (*.pdf) | *.pdf" 2>/dev/null)
fi
[ -z "$FICHIER" ] || [ ! -f "$FICHIER" ] && exit 0

NOM_DOC=$(basename "$FICHIER")
NOM_PROPRE=$(echo "${NOM_DOC%.*}" | tr -cd '[:alnum:]_-' | cut -c 1-45)
[ -z "$NOM_PROPRE" ] && NOM_PROPRE="Document_PDF"

echo -e "\n\033[1;36m📄 [Extraction Intégrale PDF] Lecture complète de : $NOM_DOC...\033[0m"

TEXTE_ENTIER=$(python3 - "$FICHIER" << 'PYEOF'
import sys, subprocess
pdf_path = sys.argv.__getitem__(1)
txt = ""
try:
    txt = subprocess.check_output(["pdftotext", "-enc", "UTF-8", pdf_path, "-"], stderr=subprocess.DEVNULL).decode("utf-8", errors="ignore")
except Exception:
    try:
        from pypdf import PdfReader
        reader = PdfReader(pdf_path)
        txt = "\n\n".join(page.extract_text() or "" for page in reader.pages)
    except Exception:
        pass
print(txt.strip())
PYEOF
)

if [ -z "$TEXTE_ENTIER" ]; then
    echo "❌ Impossible d'extraire du texte de ce PDF (il s'agit peut-être d'un scan image)."
    exit 1
fi

DATE_NOW=$(date '+%d/%m/%Y %H:%M')
DATE_STR=$(date '+%Y%m%d_%H%M')
DOSSIER_BUREAU="$HOME/Bureau/WebIA_Dossiers"
[ ! -d "$HOME/Bureau" ] && DOSSIER_BUREAU="$HOME/Desktop/WebIA_Dossiers"
mkdir -p "$DOSSIER_BUREAU"

FICHIER_MD="$DOSSIER_BUREAU/${DATE_STR}_${NOM_PROPRE}.md"
cat << MDEOF > "$FICHIER_MD"
# 📄 Document Appris : $NOM_DOC
*Importé et mémorisé intégralement le $DATE_NOW*

---

$TEXTE_ENTIER
MDEOF

echo -e "\n=== 📄 PDF INTÉGRAL : $NOM_DOC [$DATE_NOW] ===\n$TEXTE_ENTIER\n" >> "$ROOT_DIR/memory/connaissances_web.txt"
EXTRAIT_COURT=$(echo "$TEXTE_ENTIER" | tr '\n' ' ' | cut -c 1-300)
echo "- [$DATE_NOW] Document PDF ($NOM_DOC) appris en entier : $EXTRAIT_COURT..." >> "$ROOT_DIR/memory/long_term_facts.json"

echo -e "\033[1;32m✅ PDF entièrement appris et archivé dans : $FICHIER_MD\033[0m\n"
(espeak-ng -v fr+f5 -s 145 -p 48 "Document PDF appris en entier et enregistré dans Web I A Dossiers." >/dev/null 2>&1) &
