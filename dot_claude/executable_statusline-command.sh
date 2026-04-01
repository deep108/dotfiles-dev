#!/bin/sh
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
five_hour_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

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

# Rate limit usage (5-hour and 7-day); only present for subscribers after first API call
rate_part=""
if [ -n "$five_hour_used" ] || [ -n "$seven_day_used" ]; then
    rate_pieces=""
    if [ -n "$five_hour_used" ]; then
        fh_int=$(printf "%.0f" "$five_hour_used")
        if [ "$fh_int" -ge 80 ]; then
            fh_color="$RED"
        elif [ "$fh_int" -ge 50 ]; then
            fh_color="$YELLOW"
        else
            fh_color="$GREEN"
        fi
        rate_pieces="${fh_color}5h:${fh_int}%${RESET}"
    fi
    if [ -n "$seven_day_used" ]; then
        sd_int=$(printf "%.0f" "$seven_day_used")
        if [ "$sd_int" -ge 80 ]; then
            sd_color="$RED"
        elif [ "$sd_int" -ge 50 ]; then
            sd_color="$YELLOW"
        else
            sd_color="$GREEN"
        fi
        sd_piece="${sd_color}7d:${sd_int}%${RESET}"
        if [ -n "$rate_pieces" ]; then
            rate_pieces="${rate_pieces} ${sd_piece}"
        else
            rate_pieces="$sd_piece"
        fi
    fi
    rate_part="$rate_pieces"
fi

# Assemble: "hostname  ~/path/to/dir  on  main [!]  Claude Sonnet 4.6  ctx: 87%  5h:23% 7d:45%"
# Mirrors Starship default layout: hostname, directory, git branch+status, extras
line=""
[ -n "$host_part" ] && line="${host_part}  "
line="${line}${BOLD}${CYAN}${short_cwd}${RESET}"

[ -n "$git_part" ]   && line="${line}  ${git_part}"
[ -n "$model_part" ] && line="${line}  ${model_part}"
[ -n "$ctx_part" ]   && line="${line}  ${ctx_part}"
[ -n "$rate_part" ]  && line="${line}  ${rate_part}"

printf "%b\n" "$line"
