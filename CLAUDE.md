# dotfiles-dev

Chezmoi-managed dotfiles for macOS and Linux development environments. Used by both host machines and guest VMs (macOS and Linux/Debian).

Source repo: `deep108/dotfiles-dev`

## How It Works

`chezmoi init --apply --force deep108/dotfiles-dev` is called by the bootstrap scripts in `deep108/vm-tools`. Chezmoi then handles all configuration and tool installation via templates and `run_once_before_` scripts.

## Environment Detection

`.chezmoi.toml.tmpl` sets `.host_type` automatically:
- **macOS host**: `sysctl hw.model` does NOT start with `VirtualMac` → `host_type = "host"`
- **macOS guest VM**: `sysctl hw.model` starts with `VirtualMac` → `host_type = "guest"`
- **Linux**: always `host_type = "guest"`

Templates branch on `.chezmoi.os` (`darwin` / `linux`) and `.host_type` (`host` / `guest`).

## File Layout

### Templates
| File | Purpose |
|------|---------|
| `.chezmoi.toml.tmpl` | Auto-detect host vs guest, macOS vs Linux |
| `.chezmoiignore` | Exclude VS Code settings + agent configs from host machines |
| `dot_zprofile.tmpl` | Login shell: Homebrew shellenv (macOS + Linux paths) |
| `dot_zshrc.tmpl` | Interactive shell: brew, starship, mise (guest only), claude-named helper |
| `dot_config/starship.toml.tmpl` | Guest: teal powerline badge with VM hostname; Host: default prompt |
| `dot_claude/settings.json.tmpl` | Claude Code settings with platform-aware homeDir |
| `dot_claude/CLAUDE.md` | Shared agent instructions (mise + port 18000), guest only |
| `dot_claude/rules/vm-environment.md` | Glob-scoped rules for config/infra files, guest only |

### Provisioning Scripts (execute in order)
| Script | What it does |
|--------|-------------|
| `run_once_before_00-macos-defaults.sh` | Key repeat settings (skips on Linux via `uname` check) |
| `run_onchange_before_02-install-brew-packages.sh.tmpl` | Install tools via brew (incl. diff tooling, age, kamal toolchain on Linux); VS Code via apt on Linux; mise install for Linux global tools |
| `run_once_before_03-install-claude-code.sh` | Install Claude Code CLI |
| `run_once_before_03b-install-codex.sh.tmpl` | Install Codex CLI via brew |
| `run_once_before_04-install-vscode-extensions.sh.tmpl` | Install VS Code extensions (guest only) |
| `run_onchange_before_05-install-kamal.sh.tmpl` | Install pinned Kamal version as user gem (Linux guest only) |
| `run_onchange_before_06-configure-git-delta.sh.tmpl` | Configure git to use delta as pager + diff filter |

`run_onchange_` prefix means the script re-runs whenever its contents change (e.g. when adding a brew package or bumping the kamal version pin). `run_once_` runs exactly once per VM.

### Static Files
| File | Deployed to | Notes |
|------|------------|-------|
| `dot_vscode/data/User/settings.json` | `~/.vscode/data/User/settings.json` | Guest only (via .chezmoiignore) |
| `dot_local/bin/executable_check-dev-tool-updates.tmpl` | `~/.local/bin/check-dev-tool-updates` | Interactive update checker |
| `dot_codex/symlink_AGENTS.md` | `~/.codex/AGENTS.md` | Symlink to `~/.claude/CLAUDE.md`, guest only |
| `dot_gemini/symlink_GEMINI.md` | `~/.gemini/GEMINI.md` | Symlink to `~/.claude/CLAUDE.md`, guest only |

## Package Lists

### Brew Formulae (both macOS and Linux guests)
mise, starship, tmux, neovim, jq, wget, tree, htop, watch, git-delta, tig, difftastic, age

### Brew Formulae (Linux guests only — Kamal toolchain)
docker, docker-buildx

### Brew over OS (both guests — newer versions than OS ships)
curl, openssl, git, rsync, zip, unzip

### Brew Casks (macOS guest only)
Visual Studio Code, iTerm2, font-meslo-lg-nerd-font

### Brew Formulae (macOS host only)
neovim, openssl, starship, tart, tmux, git-credential-manager

### Brew Casks (macOS host only)
Google Chrome, iTerm2, font-meslo-lg-nerd-font

### Linux-specific (via apt, in run_onchange_before_02)
VS Code (from Microsoft's apt repo — brew casks are macOS-only)

### Mise-managed Runtimes (Linux guest only — global config in `~/.config/mise/config.toml`)
ruby (3.4 with `compile = false` for precompiled binaries)

### User Gems (Linux guest only — installed via `gem install --user-install`)
kamal (pinned in `run_onchange_before_05`)

## Homebrew Paths

- macOS: `/opt/homebrew/bin/brew` (Apple Silicon) or `/usr/local/bin/brew` (Intel)
- Linux: `/home/linuxbrew/.linuxbrew/bin/brew`

All shell configs and scripts handle both paths via templates or fallback detection.

## Key Conventions

- `run_once_before_00` uses a runtime `uname` check to skip on Linux (`.chezmoiignore` doesn't work for `run_*_` scripts)
- `run_onchange_before_02` uses `install_or_upgrade` (checks `brew list` not `command -v`) for brew-over-OS tools so brew version gets installed even when OS version exists
- `run_onchange_before_02` runs `mise install` after brew installs (Linux only) to materialize runtimes from `~/.config/mise/config.toml`
- chezmoi is installed by bootstrap (not by run_once scripts) — it's in `check-dev-tool-updates` but not in the install scripts
- Auto-updating tools (Claude Code, Google Chrome, iTerm2) are excluded from `check-dev-tool-updates`
- Kamal install (`run_onchange_before_05`) is gated on `.chezmoi.os == "linux"` and `.host_type == "guest"` — exits cleanly otherwise. Tart macOS guests can't run Docker so deploys come from Linux guests only.
