input=$(cat)

BOLD='\033[1m'
DIM='\033[2m'
BLUE='\033[34m'
GREEN='\033[32m'
CYAN='\033[36m'
YELLOW='\033[33m'
RED='\033[31m'
MAGENTA='\033[35m'
RESET='\033[0m'

# ─── Model ───────────────────────────────────────────────────
model_id=$(echo "$input" | jq -r '.model.id // ""')
case "$model_id" in
  *opus*)   model_label="opus"   ; model_color=$MAGENTA ;;
  *sonnet*) model_label="sonnet" ; model_color=$CYAN    ;;
  *haiku*)  model_label="haiku"  ; model_color=$GREEN   ;;
  *)        model_label=""       ; model_color=$DIM     ;;
esac

# ─── Path ────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)

if [ -n "$root" ]; then
  repo=$(basename "$root")
  if [ "$cwd" = "$root" ]; then
    display_path="$repo"
  else
    display_path="$repo/${cwd#$root/}"
  fi
else
  display_path="${cwd/#$HOME/~}"
fi

# ─── Git ─────────────────────────────────────────────────────
branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)

if [ -n "$branch" ]; then
  case "$branch" in
    main|master)             branch_color=$BLUE   ;;
    develop|dev)             branch_color=$CYAN   ;;
    feature/*|feat/*)        branch_color=$GREEN  ;;
    hotfix/*|fix/*|bugfix/*) branch_color=$RED    ;;
    release/*)               branch_color=$YELLOW ;;
    *)                       branch_color=$RESET  ;;
  esac

  git_status=$(git -C "$cwd" status --short 2>/dev/null)
  added=$(echo "$git_status"     | grep -c "^A"       2>/dev/null || echo 0)
  modified=$(echo "$git_status"  | grep -c "^.M\|^M"  2>/dev/null || echo 0)
  deleted=$(echo "$git_status"   | grep -c "^.D\|^D"  2>/dev/null || echo 0)
  untracked=$(echo "$git_status" | grep -c "^??"       2>/dev/null || echo 0)

  changes=""
  [ "$added"     -gt 0 ] && changes="${changes}+${added}"
  [ "$modified"  -gt 0 ] && changes="${changes}~${modified}"
  [ "$deleted"   -gt 0 ] && changes="${changes}-${deleted}"
  [ "$untracked" -gt 0 ] && changes="${changes}?${untracked}"

  upstream=$(git -C "$cwd" rev-parse --abbrev-ref @{upstream} 2>/dev/null)
  if [ -n "$upstream" ]; then
    ahead=$(git  -C "$cwd" rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
    behind=$(git -C "$cwd" rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)
    [ "$ahead"  -gt 0 ] && changes="${changes} ⬆${ahead}"
    [ "$behind" -gt 0 ] && changes="${changes} ⬇${behind}"
  fi

  stash_count=$(git -C "$cwd" stash list 2>/dev/null | wc -l | tr -d ' ')
  [ "$stash_count" -gt 0 ] && changes="${changes} ≡${stash_count}"

  [ -n "$changes" ] && git_info=" $changes" || git_info=""
fi

# ─── Exit code ───────────────────────────────────────────────
exit_code=$(echo "$input" | jq -r '.last_command_exit_code // empty')
if [ -n "$exit_code" ] && [ "$exit_code" != "0" ]; then
  exit_indicator=" ${RED}✗${exit_code}${RESET}"
else
  exit_indicator=""
fi

# ─── Context animation ───────────────────────────────────────
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
tokens_used=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
used_int=$(printf "%.0f" "$used_pct")

frame=$(( $(date +%s) % 8 ))
SPIN=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧")
PULSE=("·" "·" "◦" "○" "◉" "○" "◦" "·")
spin="${SPIN[$frame]}"
pulse="${PULSE[$frame]}"

make_bar() {
  local pct=$1 f=$2 width=8
  local filled=$(( pct * width / 100 ))
  local frontier=("░" "▒" "▓" "▒")
  local bar=""
  for ((i=0; i<width; i++)); do
    if   [ $i -lt $(( filled - 1 )) ]; then
      bar+="█"
    elif [ $i -eq $(( filled - 1 )) ] && [ "$filled" -gt 0 ]; then
      bar+="${frontier[$((f % 4))]}"
    else
      bar+="·"
    fi
  done
  echo "$bar"
}

fmt_k() {
  [ "$1" -ge 1000 ] && echo "$(( $1 / 1000 ))k" || echo "$1"
}

# Four states: pulse → spinner+% → bar+% → urgent bar+%+tokens
if [ "$used_int" -lt 40 ]; then
  printf "${GREEN}${pulse}${RESET} "
elif [ "$used_int" -lt 70 ]; then
  printf "${CYAN}${spin} ${used_int}%%${RESET} "
elif [ "$used_int" -lt 85 ]; then
  bar=$(make_bar "$used_int" "$frame")
  printf "${YELLOW}${spin} ${DIM}${bar}${RESET}${YELLOW} ${used_int}%%${RESET} "
else
  bar=$(make_bar "$used_int" "$frame")
  used_k=$(fmt_k "$tokens_used")
  printf "${BOLD}${RED}${spin} ${bar} ${used_int}%% ${DIM}${used_k}${RESET} "
fi

# ─── Output ──────────────────────────────────────────────────
printf "${BOLD}%s${RESET}" "$display_path"

if [ -n "$branch" ]; then
  printf " ${branch_color}⎇ %s${RESET}" "$branch"
  [ -n "$git_info" ] && printf "${DIM}%s${RESET}" "$git_info"
fi

[ -n "$model_label" ] && printf " ${DIM}·${RESET} ${model_color}%s${RESET}" "$model_label"

printf "%s\n" "$exit_indicator"
