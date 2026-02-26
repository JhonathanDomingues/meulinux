#!/usr/bin/env bash
set -u -o pipefail

NAME="ubuntu-dev"
ROOT_ARGS=()

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    ROOT_ARGS+=(--root)
fi

if distrobox list "${ROOT_ARGS[@]}" | grep -q "$NAME"; then
    echo "$NAME já existe"
    exit 0
fi

echo "Criando container $NAME..."

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
apt install -y python3 python3-pip python3-venv git curl build-essential &&
pip install --user poetry
"
then
    echo "❌ Falha ao provisionar $NAME"
    exit 1
fi

echo "$NAME pronto"