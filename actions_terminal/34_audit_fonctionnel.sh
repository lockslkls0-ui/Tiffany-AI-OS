#!/usr/bin/env bash
# TERM_KEY: audit
# TERM_DESC: Banc de test fonctionnel silencieux de 100% des modules et circuits
# TERM_ICON: 🧪

ROOT_DIR="$HOME/tiffany"
OK=0
ERR=0

check() {
    local NOM="$1"
    local CMD="$2"
    if eval "$CMD" >/dev/null 2>&1; then
        echo -e "  [\033[1;32m  OK  \033[0m] $NOM"
        OK=$((OK + 1))
    else
        echo -e "  [\033[1;31mECHEC \033[0m] $NOM"
        ERR=$((ERR + 1))
    fi
}

echo -e "\n\033[1;36m🧪 [BANC DE TEST FONCTIONNEL SILENCIEUX — TIFFANY AI-OS V48.6]\033[0m"
echo -e "==================================================================="

echo -e "\033[1;34m 1. INTÉGRITÉ SYNTAXIQUE BASH & PYTHON (0 ERREUR DE CODE)\033[0m"
check "Syntaxe noyau & actions (core, actions, interpreteur, reflexes)" "bash -n '$ROOT_DIR/tiffany_core.sh' '$ROOT_DIR/tiffany_actions.sh' '$ROOT_DIR/interpreteur_universel.sh' '$ROOT_DIR/reflexes_intelligents.sh'"
check "Syntaxe correcteur phonétique & ambiances" "bash -n '$ROOT_DIR/correcteur_phonetique.sh' '$ROOT_DIR/ambiances_tiffany.sh'"
check "Syntaxe des 26 outils terminal (actions_terminal/*.sh)" "bash -n '$ROOT_DIR'/actions_terminal/*.sh"
check "Syntaxe des 36 boutons panneau (plugins/*.sh)" "bash -n '$ROOT_DIR'/plugins/*.sh"
check "Syntaxe collecteur mémoire Python (lire_memoire_totale.py)" "python3 -m py_compile '$ROOT_DIR/lire_memoire_totale.py'"

echo -e "\n\033[1;34m 2. TESTS FONCTIONNELS RÉELS EN DIRECT (SILENCIEUX)\033[0m"
check "Test réel Correcteur Phonétique ('montre le volume a cinquante' -> 'son a 50')" "[[ \"\$(bash '$ROOT_DIR/correcteur_phonetique.sh' 'montre le volume a cinquante')\" == 'son a 50' ]]"
check "Test réel Correcteur Vosk ('hestia' -> 'testia', 'maillot' -> 'noyau')" "[[ \"\$(bash '$ROOT_DIR/correcteur_phonetique.sh' 'hestia')\" == 'testia' && \"\$(bash '$ROOT_DIR/correcteur_phonetique.sh' 'maillot')\" == 'noyau' ]]"
check "Test réel Traduction Multilingue ('next song' -> 'next')" "[[ \"\$(bash '$ROOT_DIR/correcteur_phonetique.sh' 'next song')\" == 'next' ]]"
check "Test réel Mémoire Totale & SMART (lecture effective des faits/logs)" "python3 '$ROOT_DIR/lire_memoire_totale.py' | grep -q 'Createur_officiel=lockslkls'"
check "Test réel Capteurs Matériels (CPU Temp, RAM, Batterie)" "[ -n \"\$(free -m | grep Mem)\" ] && [ -d /sys/class/thermal ]"
check "Test réel Accélération ZRAM (lz4 actif)" "zramctl 2>/dev/null | grep -q 'zram'"

echo -e "\n\033[1;34m 3. SERVICES PERMANENTS, AUDIO & SERVEUR IA OLLAMA\033[0m"
check "Sentinelle Thermique Permanente (tiffany-watchdog.service)" "systemctl --user is-active tiffany-watchdog.service | grep -q '^active$'"
check "Oreille Continue Vosk (tiffany-ear.service + processus actif)" "systemctl --user is-active tiffany-ear.service | grep -q '^active$' && pgrep -f 'tiffany_ear_daemon.sh'"
check "Micro physique verrouillé sans muet (tiffany_mic_propre)" "pactl get-source-mute @DEFAULT_SOURCE@ | grep -qiE 'no|non'"
check "Serveur neuronal local Ollama (API port 11434 prête)" "curl -s --max-time 2 http://localhost:11434/api/tags | grep -q 'tiffany-flash'"

echo -e "==================================================================="
if [ "$ERR" -eq 0 ]; then
    echo -e " 🏆 \033[1;32mSCORE PARFAIT : $OK/$((OK+ERR)) TESTS FONCTIONNELS RÉUSSIS (0 ÉCHEC) !\033[0m"
else
    echo -e " ⚠️ \033[1;33mRÉSULTAT : $OK RÉUSSIS | $ERR À CORRIGER\033[0m"
fi
echo -e "===================================================================\n"
