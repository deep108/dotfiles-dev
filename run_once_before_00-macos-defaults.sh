#!/bin/zsh
# Disable press-and-hold for key repeat (enables Vim-style navigation)

set -euo pipefail

defaults write -g ApplePressAndHoldEnabled -bool false
echo "✓ Disabled press-and-hold for key repeat"
