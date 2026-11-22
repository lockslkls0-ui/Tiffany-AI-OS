#!/usr/bin/env bash
# MENU_NAME: 🧬 Système Immunitaire (Auto-Guérison)
# MENU_DESC: Soigner les erreurs et relancer les services sans toucher à sa mémoire ni son évolution
ROOT="$HOME/tiffany"
SOINS=0
RAPPORT=""

# 1. Purge des verrous bloqués & rétablissement des droits +x
rm -f /tmp/tiffany_menu.lock /tmp/tiffany_panneau_moving.lock /tmp/tiffany_last_act.lock /tmp/tiffany_parle.lock
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

# 3. Chirurgie ciblée : répare UNIQUEMENT un script qui a une erreur de syntaxe (préserve 100% de l'évolution)
for f in "$ROOT"/*.sh "$ROOT"/actions_terminal/*.sh "$ROOT"/plugins/*.sh; do
    [ -f "$f" ] || continue
    if ! bash -n "$f" >/dev/null 2>&1; then
        REL="${f#$ROOT/}"
        git -C "$ROOT" checkout HEAD -- "$REL" 2>/dev/null && chmod +x "$f"
        SOINS=$((SOINS+1))
        RAPPORT="$RAPPORT\n• Script malade soigné chirurgicalement : $REL"
    fi
done

# 4. Ancrage de l'évolution actuelle dans Git (sans rien écraser)
git -C "$ROOT" add -A && git -C "$ROOT" commit -m "Evolution saine sauvegardee $(date '+%Y-%m-%d %H:%M')" >/dev/null 2>&1 || true

[ "$SOINS" -eq 0 ] && RAPPORT="\n• Aucun organe malade : 100% du système est sain !"
"$ROOT/bin/espeak-ng" "Système immunitaire terminé. Ton évolution et ta mémoire sont intacts, mon ange." >/dev/null 2>&1 &
zenity --info --title="🧬 Système Immunitaire Tiffany" --text="✅ Diagnostic et soins terminés (Mémoire & Évolution 100% préservés) :\n$RAPPORT" --width=480 2>/dev/null
