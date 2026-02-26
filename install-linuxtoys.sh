#!/usr/bin/env bash
set -e

REPO="vinceliuice/LinuxToys"
INSTALL_DIR="$HOME/.local/bin"
VERSION_FILE="$HOME/.local/share/linuxtoys.version"

mkdir -p "$INSTALL_DIR"
mkdir -p "$(dirname "$VERSION_FILE")"

echo "Verificando versão mais recente..."

API=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")

LATEST_VERSION=$(echo "$API" | grep tag_name | cut -d '"' -f4)

if [[ -f "$VERSION_FILE" ]]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")

    if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
        echo "LinuxToys já atualizado ($CURRENT_VERSION)"
        exit 0
    fi
fi

DOWNLOAD_URL=$(echo "$API" |
    grep browser_download_url |
    grep AppImage |
    cut -d '"' -f4 |
    head -n1)

echo "Atualizando LinuxToys → $LATEST_VERSION"

curl -L "$DOWNLOAD_URL" \
    -o "$INSTALL_DIR/linuxtoys.AppImage"

chmod +x "$INSTALL_DIR/linuxtoys.AppImage"

echo "$LATEST_VERSION" > "$VERSION_FILE"

echo "LinuxToys atualizado com sucesso."