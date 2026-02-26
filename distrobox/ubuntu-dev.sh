#!/usr/bin/env bash

if distrobox list | grep -q ubuntu-dev; then
    echo "ubuntu-dev já existe"
    exit 0
fi

echo "Criando container ubuntu-dev..."

distrobox create \
    --name ubuntu-dev \
    --image ubuntu:24.04 \
    --init \
    --yes

distrobox enter ubuntu-dev -- bash -c "
apt update &&
apt install -y python3 python3-pip python3-venv git curl build-essential &&
pip install --user poetry
"

echo "ubuntu-dev pronto"