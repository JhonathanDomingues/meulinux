#!/usr/bin/env bash
set -u -o pipefail

REPO="vinceliuice/LinuxToys"
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

if [[ -z "$TARGET_HOME" ]]; then
    TARGET_HOME="$HOME"
fi

INSTALL_DIR="$TARGET_HOME/.local/bin"
VERSION_FILE="$TARGET_HOME/.local/share/linuxtoys.version"

mkdir -p "$INSTALL_DIR"
mkdir -p "$(dirname "$VERSION_FILE")"

echo "Verificando versão mais recente..."

if ! API=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest"); then
    echo "❌ Falha ao consultar a API do GitHub para $REPO"
    exit 1
fi

LATEST_VERSION=$(echo "$API" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)

if [[ -z "$LATEST_VERSION" ]]; then
    echo "❌ Não foi possível identificar a versão mais recente do LinuxToys"
    exit 1
fi

if [[ -f "$VERSION_FILE" ]]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")

    if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
        echo "LinuxToys já atualizado ($CURRENT_VERSION)"
        exit 0
    fi
fi

DOWNLOAD_URL=$(echo "$API" |
    sed -n 's/.*"browser_download_url":[[:space:]]*"\([^"]*\)".*/\1/p' |
    grep -i 'appimage' |
    head -n1)

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "❌ Não foi possível localizar o AppImage no release $LATEST_VERSION"
    exit 1
fi

echo "Atualizando LinuxToys → $LATEST_VERSION"

if ! curl -fL "$DOWNLOAD_URL" -o "$INSTALL_DIR/linuxtoys.AppImage"; then
    echo "❌ Falha ao baixar LinuxToys de: $DOWNLOAD_URL"
    exit 1
fi

chmod +x "$INSTALL_DIR/linuxtoys.AppImage"

echo "$LATEST_VERSION" > "$VERSION_FILE"

echo "LinuxToys atualizado com sucesso."