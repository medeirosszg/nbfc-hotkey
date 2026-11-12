#!/usr/bin/env bash
# Instalação em uma linha:
#   curl -fsSL https://raw.githubusercontent.com/medeirosszg/nbfc-hotkey/main/install.sh | bash
set -euo pipefail

REPO="${NBFC_HOTKEY_REPO:-medeirosszg/nbfc-hotkey}"
BRANCH="${NBFC_HOTKEY_BRANCH:-main}"

if ! command -v python3 >/dev/null 2>&1; then
    echo "Instale o python3 primeiro. / Please install python3 first." >&2
    exit 1
fi
if [ "$(id -u)" -eq 0 ]; then
    echo "Rode sem sudo; a senha será pedida quando precisar. / Run without sudo." >&2
    exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/nbfc-hotkey" -o "$tmp/nbfc-hotkey"

# Com "curl | bash" a entrada é o próprio script; as perguntas precisam do terminal.
if [ ! -t 0 ] && [ -r /dev/tty ]; then
    exec </dev/tty
fi
python3 "$tmp/nbfc-hotkey" install "$@"
