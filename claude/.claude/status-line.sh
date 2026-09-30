#!/usr/bin/env bash

input=$(cat)
[ -z "$input" ] && exit 0

RESET=$'\x1b[0m'
c() { printf '\x1b[1;%sm%s%s' "$1" "$2" "$RESET"; }

cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')

short_cwd() {
  local p="$1"
  [ -z "$p" ] && return
  local home="${USERPROFILE:-$HOME}"
  p="${p//\\//}"
  if [ -n "$home" ]; then
    home="${home//\\//}"
    case "${p,,}" in
      "${home,,}"*) p="~${p:${#home}}" ;;
    esac
  fi
  printf '%s' "$p"
}

get_git_branch() {
  local cwd="$1" branch
  branch=$(git --no-optional-locks -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ "$branch" = "HEAD" ] && branch=""
  printf '%s' "$branch"
}

build_bar() {
  local pct="$1" width=20
  (( pct < 0 )) && pct=0
  (( pct > 100 )) && pct=100
  local filled=$(( (pct * width + 50) / 100 ))
  local empty=$(( width - filled ))
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  printf '%s' "$bar"
}

cwd_display=$(short_cwd "$cwd")

branch=$(printf '%s' "$input" | jq -r '.workspace.git_worktree.branch // .worktree.branch // empty')
[ -z "$branch" ] && branch=$(get_git_branch "$cwd")

model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')
[ -n "$effort" ] && effort=" ($effort)"

pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // 0 | round')
bar=$(build_bar "$pct")
total_tokens=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // 0')
kb_display=$(awk -v t="$total_tokens" 'BEGIN { printf "%.1fKB", t/1024 }')

cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ]; then
  cost_display=$(awk -v c="$cost" 'BEGIN { printf "$%.2f", c }')
else
  cost_display="n/a"
fi

parts=()
parts+=("$(c 36 "📁 ${cwd_display}")")
[ -n "$branch" ] && parts+=("$(c 32 "🌿 ${branch}")")
parts+=("$(c 35 "${model}${effort}")")
parts+=("$(c 33 "[${bar}] ${kb_display}")")
parts+=("$(c 32 "${cost_display}")")

sep="${RESET} | ${RESET}"
out=""
for i in "${!parts[@]}"; do
  if [ "$i" -eq 0 ]; then
    out="${parts[$i]}"
  else
    out="${out}${sep}${parts[$i]}"
  fi
done

printf '%s' "$out"
