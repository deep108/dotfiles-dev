#!/bin/zsh
# Disable press-and-hold for key repeat (enables Vim-style navigation)
# macOS only — skip silently on Linux

set -euo pipefail

[[ "$(uname)" != "Darwin" ]] && exit 0

defaults write -g ApplePressAndHoldEnabled -bool false
echo "✓ Disabled press-and-hold for key repeat"
