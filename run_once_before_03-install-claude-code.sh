#!/bin/zsh
# Install Claude Code if not present

set -euo pipefail

if ! command -v claude &>/dev/null; then
    if [[ -x "$HOME/.local/bin/claude" ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "Installing Claude Code..."
        installed=false
        for attempt in 1 2 3; do
            if curl -fsSL https://claude.ai/install.sh | bash >/dev/null 2>&1; then
                installed=true
                break
            fi
            echo "  Attempt $attempt failed — retrying in 5s..."
            sleep 5
        done
        if [[ "$installed" == true ]]; then
            export PATH="$HOME/.local/bin:$PATH"
        else
            echo "⚠ Claude Code install failed after 3 attempts"
            echo "  Install manually later: brew install claude-code"
            exit 0
        fi
    fi
fi

if command -v claude &>/dev/null; then
    claude_version=$(claude --version 2>/dev/null | awk 'NR==1' || echo "unknown")
    echo "✓ Claude Code ($claude_version)"
else
    echo "⚠ Claude Code not available"
    echo "  Install manually later: brew install claude-code"
fi
