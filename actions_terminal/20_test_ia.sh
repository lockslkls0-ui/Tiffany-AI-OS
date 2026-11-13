#!/usr/bin/env bash
# TERM_KEY: testia
# TERM_DESC: Grand Stress Test et audit de tous les modules V47.6
# TERM_ICON: 🧪

ROOT_DIR="$HOME/tiffany"
ACTION_DIR="$ROOT_DIR/actions_terminal"
PLUGIN_DIR="$ROOT_DIR/plugins"

echo -e "\n\033[1;35m🧪 [GRAND AUDIT D'INTÉGRITÉ MATRICE HYBRIDE V47.6] :\033[0m"
echo -e "\033[1;34mVérification complète de tes circuits, boucliers, sens et modules...\033[0m\n"
sleep 0.2

echo -e "\033[1;36m[ CERVEAUX IA, SENTINELLE & ACCÉLÉRATION MÉMOIRE ]\033[0m"
ollama list 2>/dev/null | grep -q "tiffany-flash" && echo -e " [\033[1;32m  OK  \033[0m] Petit Cerveau identitaire (tiffany-flash) ancré." || echo -e " [\033[1;31mMANQUE\033[0m] Petit Cerveau (tiffany-flash) non créé."
ollama list 2>/dev/null | grep -q "qwen2.5:1.5b" && echo -e " [\033[1;32m  OK  \033[0m] Gros Cerveau analytique (qwen2.5:1.5b) prêt." || echo -e " [\033[1;31mMANQUE\033[0m] Gros Cerveau (qwen2.5:1.5b) absent."
systemctl --user is-active tiffany-watchdog.service 2>/dev/null | grep -q "^active$" && echo -e " [\033[1;32m  OK  \033[0m] Sentinelle Thermique Auto-Régulée (systemd) active." || echo -e " [\033[1;31mALERTE\033[0m] Sentinelle Thermique inactive."
zramctl 2>/dev/null | grep -q "zram" && echo -e " [\033[1;32m  OK  \033[0m] Compression RAM ZRAM (lz4) opérationnelle." || echo -e " [\033[1;31mALERTE\033[0m] Compression ZRAM non détectée."
[ -d "$ROOT_DIR/voice/vosk-fr/vosk-model-small-fr-0.22" ] && echo -e " [\033[1;32m  OK  \033[0m] Sens de l'Ouïe locale (Vosk FR) opérationnel." || echo -e " [\033[1;31mMANQUE\033[0m] Modèle vocal Vosk absent."
[ -d "$ROOT_DIR/dojo" ] && [ -x "$ROOT_DIR/tiffany_training.sh" ] && echo -e " [\033[1;32m  OK  \033[0m] Bac à sable Dojo et script d'entraînement prêts." || echo -e " [\033[1;31mMANQUE\033[0m] Dojo d'entraînement incomplet."

echo -e "\n\033[1;36m[ PANOPLIE DES OUTILS DU TERMINAL (ACTIONS_TERMINAL) ]\033[0m"
for script in "$ACTION_DIR"/*.sh; do
    [ -e "$script" ] || continue
    NOM_S=$(basename "$script")
    [ -x "$script" ] && echo -e " [\033[1;32m  OK  \033[0m] Outil Terminal aligné : $NOM_S" || echo -e " [\033[1;31mALERTE\033[0m] Outil non exécutable : $NOM_S"
done

echo -e "\n\033[1;36m[ ÉCOSYSTÈME DES BOUTONS DU PANNEAU GRAPHIQUE (PLUGINS) ]\033[0m"
for plug in "$PLUGIN_DIR"/*.sh; do
    [ -e "$plug" ] || continue
    NOM_P=$(basename "$plug")
    [ -x "$plug" ] && echo -e " [\033[1;32m  OK  \033[0m] Bouton Panneau aligné : $NOM_P" || echo -e " [\033[1;31mALERTE\033[0m] Bouton non exécutable : $NOM_P"
done
echo ""
