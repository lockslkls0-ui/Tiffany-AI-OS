#!/usr/bin/env bash
pactl unload-module module-echo-cancel >/dev/null 2>&1 || true
VRAI_SINK=$(pactl list short sinks 2>/dev/null | awk "{print \$2}" | head -n 1)
[ -n "$VRAI_SINK" ] && pactl set-default-sink "$VRAI_SINK" >/dev/null 2>&1 || true
VRAI_MICRO=$(pactl list short sources 2>/dev/null | awk "{print \$2}" | grep -v "\.monitor" | head -n 1)
[ -n "$VRAI_MICRO" ] && pactl set-default-source "$VRAI_MICRO" >/dev/null 2>&1 || true
pactl set-source-mute @DEFAULT_SOURCE@ 0 >/dev/null 2>&1 || true
pactl set-source-volume @DEFAULT_SOURCE@ 85% >/dev/null 2>&1 || true
amixer sset "Internal Mic Boost" 50% >/dev/null 2>&1 || amixer sset "Mic Boost" 50% >/dev/null 2>&1 || true
amixer sset Capture cap 80% >/dev/null 2>&1 || true
