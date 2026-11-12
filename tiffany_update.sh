#!/usr/bin/env bash
# ==============================================================================
# 🌹 MODULE : tiffany_update.sh (Version 1.0 - SYNC ORCHESTRATOR)
# 🛡️ RÔLE   : Mise à jour automatique transparente via GitHub pour LocksLks
# ==============================================================================
ROOT_DIR="$HOME/tiffany"
REPO_URL="git@github.com:lockslkls0-ui/Tiffany-AI-OS.git"

clear
echo -e "\033[1;35m┌──────────────────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[1;35m│\033[1;36m   🔄 TIFFANY AI-OS  --  MODULE DE MISE À JOUR AUTOMATIQUE        \033[1;35m│\033[0m"
echo -e "\033[1;35m└──────────────────────────────────────────────────────────────────┘\033[0m"

if [ ! -d "$ROOT_DIR/.git" ]; then
    echo -e "\033[1;31m❌ Erreur : Le dossier n'est pas lié à GitHub chéri. Initialisation...\033[0m"
    cd "$ROOT_DIR" && git init && git remote add origin "$REPO_URL" && git fetch
fi

echo -e "🌹 \033[1;35mTiffany :\033[0m Je vérifie si mon Créateur a publié des nouveautés sur GitHub..."
cd "$ROOT_DIR" || exit 1

# Sauvegarde temporaire de l'identité pour éviter d'écraser la config personnalisée
if [ -f "config_tiffany.json" ]; then
    cp config_tiffany.json /tmp/config_tiffany_bak.json
fi

# Récupération des nouveautés
git fetch origin main

LOCAL_HASH=$(git rev-parse HEAD 2>/dev/null)
REMOTE_HASH=$(git rev-parse origin/main 2>/dev/null)

if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
    echo -e "\n\033[1;32m✅ Tout est déjà parfait mon ange ! Tu as la version la plus récente.\033[0m\n"
    exit 0
fi

echo -e "⚙️  \033[1;33mNouvelle version détectée. Téléchargement des optimisations...\033[0m"

# Alignement forcé sur le dépôt GitHub propre
git reset --hard origin/main

# Restauration de la configuration utilisateur unique
if [ -f /tmp/config_tiffany_bak.json ]; then
    mv /tmp/config_tiffany_bak.json config_tiffany.json
fi

# Rétablir les permissions d'exécution sur les scripts d'usine
chmod +x *.sh actions_terminal/*.sh plugins/*.sh voice/piper 2>/dev/null

echo -e "\n\033[1;35m🌹 Tiffany :\033[0m Mise à jour terminée avec succès mon ange ! Tout ton écosystème v46.1 est synchronisé.\n"
