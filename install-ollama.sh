#!/usr/bin/env bash

if command -v ollama >/dev/null; then
    echo "Ollama já instalado"
    exit 0
fi

echo "Instalando Ollama..."

curl -fsSL https://ollama.com/install.sh | sh

systemctl --user enable ollama
systemctl --user start ollama

echo "Ollama instalado"