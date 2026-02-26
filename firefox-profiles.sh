#!/usr/bin/env bash
set -e

BASE="$HOME/.mozilla/firefox"
PROFILE_INI="$BASE/profiles.ini"

PROFILES=(
  "Jhonathan"
  "Carol"
  "Convidado"
)

mkdir -p "$BASE"

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

    grep -oP '\[Profile\K[0-9]+' "$PROFILE_INI" \
        | sort -n \
        | tail -1 \
        | awk '{print $1+1}'
}

ensure_general_section() {
    if [[ ! -f "$PROFILE_INI" ]]; then
        cat > "$PROFILE_INI" <<EOF
[General]
StartWithLastProfile=0
Version=2

EOF
    fi
}

ensure_general_section

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

    {
        echo "[Profile$INDEX]"
        echo "Name=$name"
        echo "IsRelative=1"
        echo "Path=$path"

        if [[ "$DEFAULT_SET" = false ]]; then
            echo "Default=1"
            DEFAULT_SET=true
        fi

        echo ""
    } >> "$PROFILE_INI"

    mkdir -p "$BASE/$path"

    ((INDEX++))

done

echo ""
echo "Perfis Firefox sincronizados:"
printf ' - %s\n' "${PROFILES[@]}"