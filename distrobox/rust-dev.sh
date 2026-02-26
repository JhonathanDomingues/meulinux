#!/usr/bin/env bash

NAME="rust-dev"

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

curl https://sh.rustup.rs -sSf | sh -s -- -y
"

echo "Rust dev pronto"