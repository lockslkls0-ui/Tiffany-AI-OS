#!/usr/bin/env bash
RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
[ -z "$RAM_MB" ] && RAM_MB=4096

if [ "$RAM_MB" -le 5000 ]; then
    MODELE_IA="qwen2.5:0.5b"
    PROFIL="Éco (4 Go RAM)"
elif [ "$RAM_MB" -le 11000 ]; then
    MODELE_IA="qwen2.5:1.5b"
    PROFIL="Standard (8 Go RAM)"
else
    MODELE_IA="qwen2.5:7b"
    PROFIL="Performance (16 Go+ RAM)"
fi

echo "🖥️ Profil détecté : $PROFIL -> Modèle IA optimal : $MODELE_IA"
if command -v ollama >/dev/null 2>&1; then
    ollama pull "$MODELE_IA" 2>/dev/null || true
fi
