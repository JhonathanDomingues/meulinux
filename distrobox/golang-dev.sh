#!/usr/bin/env bash
set -u -o pipefail

NAME="golang-dev"
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

echo "$NAME criado. Provisionamento inicial será feito no primeiro 'distrobox enter $NAME'."