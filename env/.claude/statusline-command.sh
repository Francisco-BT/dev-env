nput=$(cat)

BOLD='\033[1m'
BLUE='\033[34m'
GREEN='\033[32m'
CYAN='\033[36m'
YELLOW='\033[33m'
RED='\033[31m'
DIM='\033[2m'
RESET='\033[0m'

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
rel_path=$(realpath --relative-to="$root" "$cwd" 2>/dev/null)

branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)

# Git status: tipo de cambios, push/pull
if [ -n "$branch" ]; then
  git_status=$(git -C "$cwd" status --short 2>/dev/null)
  
  # Contar tipos de cambios
  added=$(echo "$git_status" | grep -c "^A" 2>/dev/null || echo "0")
  modified=$(echo "$git_status" | grep -c "^.M\|^M" 2>/dev/null || echo "0")
  deleted=$(echo "$git_status" | grep -c "^.D\|^D" 2>/dev/null || echo "0")
  untracked=$(echo "$git_status" | grep -c "^??" 2>/dev/null || echo "0")
  
  # Construir indicador de cambios
  changes=""
  [ "$added" -gt 0 ] && changes="${changes}+${added}"
  [ "$modified" -gt 0 ] && changes="${changes}~${modified}"
  [ "$deleted" -gt 0 ] && changes="${changes}-${deleted}"
  [ "$untracked" -gt 0 ] && changes="${changes}?${untracked}"
  
  # Push/Pull indicators
  upstream=$(git -C "$cwd" rev-parse --abbrev-ref @{upstream} 2>/dev/null)
  if [ -n "$upstream" ]; then
    ahead=$(git -C "$cwd" rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
    behind=$(git -C "$cwd" rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")
    
    sync=""
    [ "$ahead" -gt 0 ] && sync="${sync}⬆${ahead}"
    [ "$behind" -gt 0 ] && sync="${sync}⬇${behind}"
    
    [ -n "$sync" ] && changes="${changes} ${sync}"
  fi
  
  [ -n "$changes" ] && git_info=" ${changes}" || git_info=""
else
  git_info=""
fi

# Exit code del último comando
exit_code=$(echo "$input" | jq -r '.last_command_exit_code // empty')
if [ -n "$exit_code" ] && [ "$exit_code" != "0" ]; then
  exit_indicator=" ${RED}✗${exit_code}${RESET}"
else
  exit_indicator=""
fi

# Context window usage
used_percentage=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
used_int=$(printf "%.0f" "$used_percentage")

current_second=$(date +%s)
anim_frame=$((current_second % 10))

get_spinner() {
  local frame=$1
  local spinners=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  echo "${spinners[$frame]}"
}

create_mini_bar() {
  local pct=$1
  local frame=$2
  local filled=$((pct / 10))
  local empty=$((10 - filled))
  local bar=""
  
  for ((i=0; i<filled; i++)); do
    if [ $i -eq $((filled - 1)) ] && [ $filled -lt 10 ]; then
      case $((frame % 3)) in
        0) bar+="▓" ;;
        1) bar+="▒" ;;
        2) bar+="░" ;;
      esac
    else
      bar+="█"
    fi
  done
  
  for ((i=0; i<empty; i++)); do bar+="░"; done
  echo "$bar"
}

# Context indicator
if [ "$used_int" -lt 50 ]; then
  icon=$(get_spinner $anim_frame)
  [ "$used_int" -lt 30 ] && ctx_color=$GREEN || ctx_color=$CYAN
  printf "${ctx_color}${icon}${RESET} "
  
elif [ "$used_int" -lt 70 ]; then
  icon=$(get_spinner $anim_frame)
  printf "${YELLOW}${icon} ${used_int}%%${RESET} "
  
else
  icon=$(get_spinner $anim_frame)
  mini_bar=$(create_mini_bar "$used_int" $anim_frame)
  [ "$used_int" -lt 85 ] && ctx_color=$YELLOW || ctx_color=$RED
  [ "$used_int" -lt 85 ] && weight="" || weight=$BOLD
  printf "${weight}${ctx_color}${icon} ${used_int}%% ${DIM}${mini_bar}${RESET} "
fi

# Path
if [ -z "$rel_path" ] || [ "$rel_path" = "." ]; then
  printf "${BOLD}${DIM}~${RESET}"
else
  printf "${BOLD}%s${RESET}" "$rel_path"
fi

# Git branch + info
if [ -n "$branch" ]; then
  printf " ${BLUE}(%s%s)${RESET}" "$branch" "$git_info"
fi

# Exit code indicator
printf "%s" "$exit_indicator"

printf '\n'
