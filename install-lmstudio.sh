#!/usr/bin/env bash
set -e -u -o pipefail

echo "===== Instalando LM Studio AppImage ====="

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

if [[ -z "$TARGET_HOME" ]]; then
    TARGET_HOME="$HOME"
fi

APPIMAGE_DIR="$TARGET_HOME/.local/share/applications/appimages"
LMSTUDIO_URL="https://lmstudio.ai/download/latest/linux/x64"
APPIMAGE_NAME="LM_Studio.AppImage"

echo "Criando diretório para AppImages..."
mkdir -p "$APPIMAGE_DIR"

echo "Baixando LM Studio..."
cd "$APPIMAGE_DIR"

if [[ -f "$APPIMAGE_NAME" ]]; then
    echo "⚠️  LM Studio AppImage já existe em $APPIMAGE_DIR"
    read -r -p "Deseja substituir? [s/N]: " answer
    case "$answer" in
        [sS]|[sS][iI][mM])
            rm -f "$APPIMAGE_NAME"
            ;;
        *)
            echo "✅ Mantendo versão existente"
            exit 0
            ;;
    esac
fi

curl -L -o "$APPIMAGE_NAME" "$LMSTUDIO_URL"

echo "Tornando executável..."
chmod +x "$APPIMAGE_NAME"

echo "Ajustando permissões..."
if [[ -n "${SUDO_USER:-}" && "$(id -u)" -eq 0 ]]; then
    chown "$TARGET_USER:$TARGET_USER" "$APPIMAGE_NAME"
fi

echo ""
echo "✅ LM Studio instalado em: $APPIMAGE_DIR/$APPIMAGE_NAME"
echo ""
echo "Para usar com Gear Lever:"
echo "  1. Abra o Gear Lever"
echo "  2. O AppImage deve aparecer automaticamente"
echo "  3. Ou adicione manualmente o caminho: $APPIMAGE_DIR/$APPIMAGE_NAME"
echo ""
