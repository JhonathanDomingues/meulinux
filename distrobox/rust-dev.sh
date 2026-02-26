#!/usr/bin/env bash
set -u -o pipefail

NAME="rust-dev"
ROOT_ARGS=()

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    ROOT_ARGS+=(--root)
fi

if distrobox list "${ROOT_ARGS[@]}" | grep -q "$NAME"; then
    echo "$NAME já existe"
    exit 0
fi

echo "Criando $NAME..."

if ! distrobox create \
    "${ROOT_ARGS[@]}" \
    --name $NAME \
    --image ubuntu:24.04 \
    --init \
    --yes
then
    echo "❌ Falha ao criar $NAME"
    exit 1
fi

if ! distrobox enter "${ROOT_ARGS[@]}" $NAME -- bash -c "
apt update &&
apt install -y curl git build-essential

curl https://sh.rustup.rs -sSf | sh -s -- -y
"
then
    echo "❌ Falha ao provisionar $NAME"
    exit 1
fi

echo "Rust dev pronto"