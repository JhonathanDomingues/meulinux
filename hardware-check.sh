#!/usr/bin/env bash

echo "Detectando hardware..."

GPU=$(lspci | grep -Ei 'vga|3d')

echo "$GPU"

# Detecta GPU e define aceleração
if echo "$GPU" | grep -qi nvidia; then
    echo ""
    echo "🎮 GPU NVIDIA detectada!"
    read -p "Ativar suporte CUDA para Ollama? (y/N): " RESP
    if [[ "$RESP" =~ ^[Yy]$ ]]; then
        export OLLAMA_GPU_DRIVER="nvidia"
    fi
elif echo "$GPU" | grep -Ei 'amd|radeon'; then
    echo ""
    echo "🎮 GPU AMD detectada!"
    read -p "Ativar suporte ROCm para Ollama? (y/N): " RESP
    if [[ "$RESP" =~ ^[Yy]$ ]]; then
        export OLLAMA_GPU_DRIVER="rocm"
    fi
fi

echo ""
if grep -qi battery /sys/class/power_supply/*/type 2>/dev/null; then
    echo "💻 Notebook detectado"
else
    echo "🖥️  Desktop detectado"
fi