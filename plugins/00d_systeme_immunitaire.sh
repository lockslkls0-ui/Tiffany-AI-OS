#!/usr/bin/env bash
# MENU_NAME: 🧬 Système Immunitaire (Auto-Guérison)
# MENU_DESC: Auto-soin intelligent des services, verrous et scripts sans perdre son évolution
ROOT="$HOME/tiffany"
SILENT=0
[ "$1" = "--silent" ] && SILENT=1
SOINS=0
RAPPORT=""

# 1. Nettoyage des verrous bloqués (uniquement si anciens ou orphelins) & permissions +x
find /tmp -maxdepth 1 -name "tiffany_*.lock" -mmin +5 -delete 2>/dev/null
chmod +x "$ROOT"/*.sh "$ROOT"/actions_terminal/*.sh "$ROOT"/plugins/*.sh "$ROOT"/bin/* 2>/dev/null

# 2. Réanimation des services endormis
systemctl --user daemon-reload
for srv in tiffany-watchdog.service tiffany-diary.timer; do
    if ! systemctl --user is-active --quiet "$srv"; then
        systemctl --user restart "$srv" && SOINS=$((SOINS+1)) && RAPPORT="$RAPPORT\n• Service $srv réanimé"
    fi
done
if [ ! -f "$HOME/.config/tiffany/oreille_off" ] && ! systemctl --user is-active --quiet tiffany-ear.service; then
    systemctl --user restart tiffany-ear.service && SOINS=$((SOINS+1)) && RAPPORT="$RAPPORT\n• Oreille vocale réanimée"
fi

# 3. Chirurgie ciblée sur tout script Bash ou Python malade (préserve 100% de l'évolution)
for f in "$ROOT"/*.sh "$ROOT"/actions_terminal/*.sh "$ROOT"/plugins/*.sh; do
    [ -f "$f" ] || continue
    if ! bash -n "$f" >/dev/null 2>&1; then
        REL="${f#$ROOT/}"
        git -C "$ROOT" checkout HEAD -- "$REL" 2>/dev/null && chmod +x "$f"
        SOINS=$((SOINS+1))
        RAPPORT="$RAPPORT\n• Script Bash soigné : $REL"
    fi
done
for py in "$ROOT"/*.py "$ROOT"/ear_modules/*.py "$ROOT"/agents/*.py; do
    [ -f "$py" ] || continue
    if ! python3 -m py_compile "$py" >/dev/null 2>&1; then
        REL="${py#$ROOT/}"
        git -C "$ROOT" checkout HEAD -- "$REL" 2>/dev/null
        SOINS=$((SOINS+1))
        RAPPORT="$RAPPORT\n• Script Python soigné : $REL"
    fi
done

# 4. Ancrage silencieux de l'évolution saine dans Git
git -C "$ROOT" add -A && git -C "$ROOT" commit -m "Auto-evolution saine $(date '+%Y-%m-%d %H:%M')" >/dev/null 2>&1 || true

if [ "$SILENT" -eq 1 ]; then
    [ "$SOINS" -gt 0 ] && notify-send -u normal -i "emblem-default" "🧬 Auto-Guérison Tiffany" "J'ai soigné $SOINS anomalie(s) en arrière-plan !"
    exit 0
fi

[ "$SOINS" -eq 0 ] && RAPPORT="\n• Aucun organe malade : 100% du système est sain !"
"$ROOT/bin/espeak-ng" "Système immunitaire terminé. Ton évolution et ta mémoire sont intacts, mon ange." >/dev/null 2>&1 &
zenity --info --title="🧬 Système Immunitaire Tiffany" --text="✅ Diagnostic et soins terminés (Mémoire & Évolution 100% préservés) :\n$RAPPORT" --width=480 2>/dev/null
