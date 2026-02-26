#!/usr/bin/env bash
set -e

echo "===== BAZZITE WORKSTATION SETUP ====="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

chmod +x *.sh distrobox/*.sh

echo "== Hardware check =="
"$SCRIPT_DIR/hardware-check.sh"

echo "== Flatpaks =="

flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo

xargs -a flatpaks.txt flatpak install -y flathub

echo "== Firefox profiles =="
"$SCRIPT_DIR/firefox-profiles.sh"

echo "== Ollama =="
"$SCRIPT_DIR/install-ollama.sh"

echo "== Distrobox ubuntu-dev =="
for script in distrobox/*.sh; do
    bash "$script"
done

echo "== LinuxToys =="
bash install-linuxtoys.sh

echo ""
echo "✅ Instalação concluída"
echo "Reboot recomendado"