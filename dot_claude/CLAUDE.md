# Dev VM Environment

## Language Runtimes — Use mise

Use **mise** for all language runtimes (Node.js, Python, Java, Go, Ruby, etc.).
- Install: `mise use node@22` (writes `.mise.toml`), then `mise trust && mise install`
- NEVER install runtimes via brew, nvm, pyenv, or other version managers
- Check versions: `mise ls` (installed), `mise ls-remote <tool>` (available)

## Reserved Port: 18000

Port 18000 is permanently used by **VS Code serve-web** (browser IDE access).
- NEVER kill processes on port 18000 — it is NOT a stale dev server
- NEVER bind dev servers to port 18000
- Service: `com.user.vscode.serve-web` (macOS launchd) / `vscode-serve-web` (Linux systemd)
- `~/.vscode/serve-web-token` is its connection token — never delete, move, or print it

## Shell Script Gotchas

- Under `set -o pipefail`, `cmd | head -1` can fail with SIGPIPE (exit 141)
  when `cmd` keeps writing after head exits — use `awk 'NR==1{...}'` instead
- Homebrew prefix differs by platform: `/opt/homebrew` (macOS) vs
  `/home/linuxbrew/.linuxbrew` (Linux) — don't hardcode either; use
  `brew --prefix` or check both
