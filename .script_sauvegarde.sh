#!/usr/bin/env bash
DOSSIER_RACINE="$HOME/Bureau/Sauvegarde_Projet"
DATE_HEURE=$(date "+%Y-%m-%d_%Hh%M")
DOSSIER_SAUVEGARDE="$DOSSIER_RACINE/Sauvegarde_$DATE_HEURE"

mkdir -p "$DOSSIER_SAUVEGARDE"

F_CODE="$DOSSIER_SAUVEGARDE/1_LOGIQUE_ET_CODE_$DATE_HEURE.txt"
F_CONFIG="$DOSSIER_SAUVEGARDE/2_CONFIG_ET_PROFIL_$DATE_HEURE.txt"
F_DICO="$DOSSIER_SAUVEGARDE/3_DICTIONNAIRES_IA_$DATE_HEURE.txt"
F_LOGS="$DOSSIER_SAUVEGARDE/4_LOGS_ET_HISTORIQUE_$DATE_HEURE.txt"

echo "=== 1. SCRIPTS ET LOGIQUE SOURCE ($DATE_HEURE) ===" > "$F_CODE"
echo "=== 2. CONFIGURATIONS ET PARAMÈTRES ($DATE_HEURE) ===" > "$F_CONFIG"
echo "=== 3. DICTIONNAIRES ET LEXIQUES ($DATE_HEURE) ===" > "$F_DICO"
echo "=== 4. JOURNAUX ET HISTORIQUE DE SESSION ($DATE_HEURE) ===" > "$F_LOGS"

# Le filtre -not -path "*/.git*" bloque définitivement l'aspiration des objets Git
find "$HOME/tiffany" -type f -not -path "*/.git*" | sort | while read -r f; do
    [[ "$f" == *".script_sauvegarde.sh"* ]] && continue

    if file "$f" | grep -q "text"; then
        CONTENU=$(cat "$f")
    else
        CONTENU="[Fichier non-texte ou binaire / Image]"
    fi

    BLOC=$'\n========================================\n▶ FICHIER : '"$f"$'\n----------------------------------------\n'"$CONTENU"$'\n'

    if [[ "$f" == *.sh ]]; then
        echo "$BLOC" >> "$F_CODE"
    elif [[ "$f" == *.json || "$f" == *.txt && ( "$f" == *contexte* || "$f" == *facts* ) ]]; then
        echo "$BLOC" >> "$F_CONFIG"
    elif [[ "$f" == *dictionnaire* ]]; then
        echo "$BLOC" >> "$F_DICO"
    else
        echo "$BLOC" >> "$F_LOGS"
    fi
done

xdg-open "$DOSSIER_SAUVEGARDE"
