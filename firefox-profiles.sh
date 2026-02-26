#!/usr/bin/env bash
set -u -o pipefail

if [[ "$(id -u)" -eq 0 && -n "${SUDO_USER:-}" ]]; then
    TARGET_USER="$SUDO_USER"
else
    TARGET_USER="${USER:-$(id -un)}"
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

if [[ -z "$TARGET_HOME" ]]; then
    TARGET_HOME="$HOME"
fi

FLATPAK_BASE="$TARGET_HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
NATIVE_BASE="$TARGET_HOME/.mozilla/firefox"

if command -v flatpak >/dev/null 2>&1 && flatpak info org.mozilla.firefox >/dev/null 2>&1; then
    BASE="$FLATPAK_BASE"
else
    BASE="$NATIVE_BASE"
fi

PROFILE_INI="$BASE/profiles.ini"

PROFILES=(
  "Jhonathan"
  "Carol"
  "Convidado"
)

FAILED_PROFILES=()

report_profile_error() {
        local name="$1"
        local message="$2"
        local exit_code="${3:-1}"
        echo "❌ Erro no perfil '$name': $message (exit $exit_code)"
        FAILED_PROFILES+=("$name: $message (exit $exit_code)")
}

mkdir -p "$BASE"

echo "Usando diretório de perfis: $BASE"

sanitize() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '_'
}

profile_exists() {
    local name="$1"
    [[ -f "$PROFILE_INI" ]] && grep -q "Name=$name" "$PROFILE_INI"
}

get_next_index() {
    if [[ ! -f "$PROFILE_INI" ]]; then
        echo 0
        return
    fi

    local last_index
    last_index=$(grep -oP '\[Profile\K[0-9]+' "$PROFILE_INI" | sort -n | tail -1)

    if [[ -z "$last_index" ]]; then
        echo 0
    else
        echo $((last_index + 1))
    fi
}

ensure_general_section() {
    if [[ ! -f "$PROFILE_INI" ]]; then
        if ! cat > "$PROFILE_INI" <<EOF
[General]
StartWithLastProfile=0
Version=2

EOF
        then
            echo "❌ Não foi possível criar $PROFILE_INI"
            return 1
        fi
    fi
}

if ! ensure_general_section; then
    exit 1
fi

INDEX=$(get_next_index)
DEFAULT_SET=false

grep -q "Default=1" "$PROFILE_INI" && DEFAULT_SET=true

for name in "${PROFILES[@]}"; do

    if profile_exists "$name"; then
        echo "Perfil já existe: $name"
        continue
    fi

    path="$(sanitize "$name").default"

    echo "Criando perfil: $name"

    set_default=false
    if [[ "$DEFAULT_SET" = false ]]; then
        set_default=true
    fi

    {
        echo "[Profile$INDEX]"
        echo "Name=$name"
        echo "IsRelative=1"
        echo "Path=$path"

        if [[ "$set_default" = true ]]; then
            echo "Default=1"
        fi

        echo ""
    } >> "$PROFILE_INI"
    write_exit_code=$?
    if [[ $write_exit_code -ne 0 ]]; then
        report_profile_error "$name" "falha ao gravar em $PROFILE_INI" "$write_exit_code"
        continue
    fi

    if [[ "$set_default" = true ]]; then
        DEFAULT_SET=true
    fi

    mkdir -p "$BASE/$path"
    mkdir_exit_code=$?
    if [[ $mkdir_exit_code -ne 0 ]]; then
        report_profile_error "$name" "falha ao criar diretório $BASE/$path" "$mkdir_exit_code"
        continue
    fi

    INDEX=$((INDEX + 1))

done

echo ""
echo "Perfis Firefox sincronizados:"
printf ' - %s\n' "${PROFILES[@]}"

if [[ ${#FAILED_PROFILES[@]} -gt 0 ]]; then
    echo ""
    echo "⚠️ Erros encontrados nos perfis:"
    printf ' - %s\n' "${FAILED_PROFILES[@]}"
    exit 1
fi