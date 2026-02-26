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
SKIPPED_STEPS=()
INSTALL_MODE=""

print_usage() {
    cat <<EOF
Uso: $(basename "$0") [--all|--ask]

  --all   Instala todas as etapas automaticamente
  --ask   Pergunta antes de executar cada etapa
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                INSTALL_MODE="all"
                ;;
            --ask)
                INSTALL_MODE="ask"
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                echo "❌ Opção inválida: $1"
                print_usage
                exit 1
                ;;
        esac
        shift
    done
}

choose_install_mode() {
    if [[ -n "$INSTALL_MODE" ]]; then
        return 0
    fi

    if [[ -t 0 ]]; then
        echo ""
        echo "Escolha o modo de instalação:"
        echo "  1) Instalar tudo"
        echo "  2) Perguntar cada etapa"

        local option
        while true; do
            read -r -p "Opção [1/2]: " option
            case "$option" in
                1)
                    INSTALL_MODE="all"
                    return 0
                    ;;
                2)
                    INSTALL_MODE="ask"
                    return 0
                    ;;
                *)
                    echo "Opção inválida. Digite 1 ou 2."
                    ;;
            esac
        done
    fi

    INSTALL_MODE="all"
}

should_run_step() {
    local label="$1"

    if [[ "$INSTALL_MODE" == "all" ]]; then
        return 0
    fi

    local answer
    while true; do
        read -r -p "Executar '$label'? [s/N]: " answer
        case "$answer" in
            [sS]|[sS][iI][mM])
                return 0
                ;;
            ""|[nN]|[nN][aA][oO]|[nN][ãÃ][oO])
                return 1
                ;;
            *)
                echo "Resposta inválida. Use 's' ou 'n'."
                ;;
        esac
    done
}

run_step_selected() {
    local label="$1"
    shift

    if should_run_step "$label"; then
        run_step "$label" "$@"
        return 0
    fi

    echo "⏭️ Pulando: $label"
    SKIPPED_STEPS+=("$label")
    return 0
}

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

parse_args "$@"
choose_install_mode

echo "Modo selecionado: $INSTALL_MODE"

run_step_selected "Hardware check" "$SCRIPT_DIR/hardware-check.sh"

run_step_selected "Flatpak remote flathub" flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo

run_step_selected "Flatpaks" xargs -a "$SCRIPT_DIR/flatpaks.txt" flatpak install -y flathub

run_step_selected "Firefox profiles" run_as_target_user bash "$SCRIPT_DIR/firefox-profiles.sh"

#desativado, utilizando o ollama que vem com o alpaca por enquanto
#echo "== Ollama =="
#"$SCRIPT_DIR/install-ollama.sh"

for script in "$SCRIPT_DIR"/distrobox/*.sh; do
    run_step_selected "Distrobox $(basename "$script" .sh)" run_as_target_user bash "$script"
done

run_step_selected "LinuxToys" run_as_target_user bash "$SCRIPT_DIR/install-linuxtoys.sh"

echo ""
if [[ ${#FAILED_STEPS[@]} -eq 0 ]]; then
    echo "✅ Instalação concluída"
else
    echo "⚠️ Instalação concluída com erros:"
    printf ' - %s\n' "${FAILED_STEPS[@]}"
fi

if [[ ${#SKIPPED_STEPS[@]} -gt 0 ]]; then
    echo "Etapas puladas:"
    printf ' - %s\n' "${SKIPPED_STEPS[@]}"
fi

echo "Reboot recomendado"