#!/usr/bin/env bash
# TERM_KEY: testia
# TERM_DESC: Grand Stress Test et audit de tous les modules V47
# TERM_ICON: 🧪

ROOT_DIR="$HOME/tiffany"
ACTION_DIR="$ROOT_DIR/actions_terminal"
PLUGIN_DIR="$ROOT_DIR/plugins"

echo -e "\n\033[1;35m🧪 [GRAND AUDIT D'INTEGRITE MATRICE HYBRIDE V47.2] :\033[0m"
echo -e "\033[1;34mVérification complète de tes circuits, boucliers et modules, mon ange...\033[0m\n"
sleep 0.2

# 1. Cerveaux & Bouclier CPU
echo -e "\033[1;36m[ CERVEAUX IA & BOUCLIER MATÉRIEL ]\033[0m"
if ollama list 2>/dev/null | grep -q "tiffany-flash"; then
    echo -e " [\033[1;32m  OK  \033[0m] Petit Cerveau identitaire (tiffany-flash) ancré."
else
    echo -e " [\033[1;31mMANQUE\033[0m] Petit Cerveau (tiffany-flash) non créé."
fi

if ollama list 2>/dev/null | grep -q "qwen2.5:1.5b"; then
    echo -e " [\033[1;32m  OK  \033[0m] Gros Cerveau analytique (qwen2.5:1.5b) prêt."
else
    echo -e " [\033[1;31mMANQUE\033[0m] Gros Cerveau (qwen2.5:1.5b) absent."
fi

if [ -f "/etc/systemd/system/ollama.service.d/limit.conf" ]; then
    echo -e " [\033[1;32m  OK  \033[0m] Bouclier CPU Systemd (Plafond 80%) actif."
else
    echo -e " [\033[1;31mALERTE\033[0m] Bouclier CPU Systemd non détecté."
fi

if [ -d "$ROOT_DIR/dojo" ] && [ -x "$ROOT_DIR/tiffany_training.sh" ]; then
    echo -e " [\033[1;32m  OK  \033[0m] Bac à sable Dojo et script d'entraînement prêts."
else
    echo -e " [\033[1;31mMANQUE\033[0m] Dojo d'entraînement incomplet."
fi

# 2. Scan dynamique de la Panoplie du Terminal
echo -e "\n\033[1;36m[ PANOPLIE DES OUTILS DU TERMINAL (ACTIONS_TERMINAL) ]\033[0m"
for script in "$ACTION_DIR"/*.sh; do
    [ -e "$script" ] || continue
    NOM_S=$(basename "$script")
    if [ -x "$script" ]; then
        echo -e " [\033[1;32m  OK  \033[0m] Outil Terminal aligné : $NOM_S"
    else
        echo -e " [\033[1;31mALERTE\033[0m] Outil non exécutable : $NOM_S"
    fi
done

# 3. Scan dynamique des Boutons du Panneau Graphique
echo -e "\n\033[1;36m[ ECOSYSTEME DES BOUTONS DU PANNEAU GRAPHIQUE (PLUGINS) ]\033[0m"
for plug in "$PLUGIN_DIR"/*.sh; do
    [ -e "$plug" ] || continue
    NOM_P=$(basename "$plug")
    if [ -x "$plug" ]; then
        echo -e " [\033[1;32m  OK  \033[0m] Bouton Panneau aligné : $NOM_P"
    else
        echo -e " [\033[1;31mALERTE\033[0m] Bouton non exécutable : $NOM_P"
    fi
done
echo ""

