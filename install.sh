#!/usr/bin/env bash
set -u -o pipefail

echo "===== BAZZITE WORKSTATION SETUP ====="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

if [[ -z "$TARGET_HOME" ]]; then
    TARGET_HOME="$HOME"
fi

FAILED_STEPS=()

run_step() {
    local label="$1"
    shift

    echo "== $label =="
    "$@"
    local exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        return 0
    fi

    echo "❌ Erro em: $label (exit $exit_code)"
    FAILED_STEPS+=("$label (exit $exit_code)")
    return 0
}

run_as_target_user() {
    if [[ -n "${SUDO_USER:-}" && "$(id -u)" -eq 0 ]]; then
        sudo -H -u "$TARGET_USER" USER="$TARGET_USER" HOME="$TARGET_HOME" "$@"
        return $?
    fi

    "$@"
}

chmod +x *.sh distrobox/*.sh

run_step "Hardware check" "$SCRIPT_DIR/hardware-check.sh"

run_step "Flatpak remote flathub" flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo

run_step "Flatpaks" xargs -a "$SCRIPT_DIR/flatpaks.txt" flatpak install -y flathub

run_step "Firefox profiles" run_as_target_user bash "$SCRIPT_DIR/firefox-profiles.sh"

#desativado, utilizando o ollama que vem com o alpaca por enquanto
#echo "== Ollama =="
#"$SCRIPT_DIR/install-ollama.sh"

for script in "$SCRIPT_DIR"/distrobox/*.sh; do
    run_step "Distrobox $(basename "$script" .sh)" run_as_target_user bash "$script"
done

run_step "LinuxToys" run_as_target_user bash "$SCRIPT_DIR/install-linuxtoys.sh"

echo ""
if [[ ${#FAILED_STEPS[@]} -eq 0 ]]; then
    echo "✅ Instalação concluída"
else
    echo "⚠️ Instalação concluída com erros:"
    printf ' - %s\n' "${FAILED_STEPS[@]}"
fi

echo "Reboot recomendado"