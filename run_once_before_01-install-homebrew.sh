#!/bin/zsh
# Install Homebrew if not present

set -euo pipefail

if ! command -v brew &>/dev/null; then
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

brew_version=$(brew --version 2>/dev/null | awk 'NR==1{print $2}')
echo "✓ Homebrew ($brew_version)"
