#!/usr/bin/env bash

NAME="golang-dev"

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
apt install -y golang git curl build-essential
"

echo "Go dev pronto"