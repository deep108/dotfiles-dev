#!/bin/zsh
# Install Claude Code if not present

set -euo pipefail

if ! command -v claude &>/dev/null; then
    if [[ -x "$HOME/.local/bin/claude" ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "Installing Claude Code..."
        curl -fsSL https://claude.ai/install.sh | bash >/dev/null
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

if command -v claude &>/dev/null; then
    claude_version=$(claude --version 2>/dev/null | awk 'NR==1' || echo "unknown")
    echo "✓ Claude Code ($claude_version)"
else
    echo "✗ Claude Code installation failed"
    exit 1
fi
