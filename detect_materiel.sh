#!/usr/bin/env bash
# Conserve strictement l'entonnoir officiel à 4 cerveaux de Tiffany AI-OS
RAM_GO=$(free -m | awk '/^Mem:/{printf "%.0f", $2/1024}')
[ -z "$RAM_GO" ] && RAM_GO=8
echo "🖥️ Mémoire détectée : ${RAM_GO} Go RAM — Entonnoir officiel 4 cerveaux activé (100% identique)."
