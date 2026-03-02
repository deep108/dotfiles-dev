#!/bin/sh
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# ANSI colors (dim-friendly, mirrors Starship default palette)
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
RED='\033[31m'
BOLD='\033[1m'
RESET='\033[0m'

# Shorten home directory to ~
home="$HOME"
short_cwd="${cwd/#$home/\~}"

# Git branch and status (run in the session cwd, skipping optional locks)
git_part=""
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git_status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
        if [ -n "$git_status" ]; then
            git_part="${GREEN}on${RESET}  ${BOLD}${BLUE}${branch}${RESET} ${YELLOW}[!]${RESET}"
        else
            git_part="${GREEN}on${RESET}  ${BOLD}${BLUE}${branch}${RESET}"
        fi
    fi
fi

# Context remaining with color thresholds
ctx_part=""
if [ -n "$remaining" ]; then
    remaining_int=$(printf "%.0f" "$remaining")
    if [ "$remaining_int" -le 20 ]; then
        ctx_color="$RED"
    elif [ "$remaining_int" -le 50 ]; then
        ctx_color="$YELLOW"
    else
        ctx_color="$GREEN"
    fi
    ctx_part="${ctx_color}ctx: ${remaining_int}%${RESET}"
fi

# Hostname
host_part=""
hostname=$(hostname -s 2>/dev/null)
[ -n "$hostname" ] && host_part="${YELLOW}${hostname}${RESET}"

# Model name
model_part=""
[ -n "$model" ] && model_part="${CYAN}${model}${RESET}"

# Assemble: "hostname  ~/path/to/dir  on  main [!]  Claude Sonnet 4.6  ctx: 87%"
# Mirrors Starship default layout: hostname, directory, git branch+status, extras
line=""
[ -n "$host_part" ] && line="${host_part}  "
line="${line}${BOLD}${CYAN}${short_cwd}${RESET}"

[ -n "$git_part" ]   && line="${line}  ${git_part}"
[ -n "$model_part" ] && line="${line}  ${model_part}"
[ -n "$ctx_part" ]   && line="${line}  ${ctx_part}"

printf "%b\n" "$line"
