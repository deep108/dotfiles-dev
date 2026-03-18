---
globs:
  - Dockerfile*
  - docker-compose*.{yml,yaml}
  - .env*
  - Makefile
  - "**/package.json"
  - "**/pyproject.toml"
  - "**/.mise.toml"
  - "**/vite.config.*"
  - "**/next.config.*"
  - "**/webpack.config.*"
  - "**/tsconfig.json"
  - "**/*.service"
  - "**/Procfile"
---
# VM Environment Details

## Homebrew
- macOS: `/opt/homebrew` (Apple Silicon)
- Linux: `/home/linuxbrew/.linuxbrew`
- Use brew for CLI tools and applications, NOT for language runtimes (use mise)

## Services
- VS Code serve-web: port 18000 (launchd/systemd, always running)
- Shell: zsh + starship prompt
- tmux available for persistent sessions
- neovim (`nvim`) available as terminal editor
