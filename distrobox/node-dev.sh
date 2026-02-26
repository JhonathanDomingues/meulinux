#!/usr/bin/env bash

NAME="node-dev"

if distrobox list | grep -q "$NAME"; then
    echo "$NAME já existe"
    exit 0
fi

echo "Criando $NAME..."

distrobox create \
    --name $NAME \
    --image ubuntu:24.04 \
    --init \
    --yes

distrobox enter $NAME -- bash -c "
apt update &&
apt install -y curl git build-essential

curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs

npm install -g pnpm yarn
"

echo "Node dev pronto"