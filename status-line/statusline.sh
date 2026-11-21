#!/usr/bin/env bash
# Claude Code status line:
# "<tokens> | Context: <pct>% | Session window: <pct>% | Weekly limit: <pct>% | Effort: <level>"
# Percentages use a three-point color gradient (0% -> 50% -> 100%).
# Shows reported values: context_window.total_input_tokens,
# context_window.used_percentage, rate_limits.five_hour.used_percentage,
# rate_limits.seven_day.used_percentage, effort.level.
# Dependencies: grep, sed, tr (no jq). Linux, macOS bash 3.2+, Git Bash on Windows.

# Set a variable to a color, or to the default when the value is empty or not a "#RRGGBB" color:
# set_color <variable name> <value> <default>
set_color() {
  local value=${2// /} hex_pattern='^#?[0-9A-Fa-f]{6}$'
  if [[ $value =~ $hex_pattern ]]; then
    printf -v "$1" '%s' "$value"
  else
    printf -v "$1" '%s' "$3"
  fi
}

# ---- Color settings --------------------------------------------------------
# Set these in the "env" block of Claude Code's settings.json. See the README.
# Write each color as a "#RRGGBB" hex value, for example "#FCEE54". The "#" is optional.
# The last value on each line is the default, used when the variable is not set, is empty,
# or does not hold a "#RRGGBB" color.
# A text color of "" uses the terminal's default text color.

# Text colors
set_color TOKEN_COUNT_COLOR "$STATUSLINE_TOKEN_COUNT_COLOR" ""
set_color CONTEXT_LABEL_COLOR "$STATUSLINE_CONTEXT_LABEL_COLOR" ""
set_color SESSION_WINDOW_LABEL_COLOR "$STATUSLINE_SESSION_WINDOW_LABEL_COLOR" ""
set_color SEPARATOR_COLOR "$STATUSLINE_SEPARATOR_COLOR" ""
set_color NO_SESSION_DATA_COLOR "$STATUSLINE_NO_SESSION_DATA_COLOR" ""
set_color WEEKLY_LIMIT_LABEL_COLOR "$STATUSLINE_WEEKLY_LIMIT_LABEL_COLOR" ""
set_color NO_WEEKLY_DATA_COLOR "$STATUSLINE_NO_WEEKLY_DATA_COLOR" ""
set_color EFFORT_LABEL_COLOR "$STATUSLINE_EFFORT_LABEL_COLOR" ""
set_color EFFORT_LEVEL_COLOR "$STATUSLINE_EFFORT_LEVEL_COLOR" ""

# Percentage gradient targets. The script blends between them for other percentages.
set_color PERCENT_COLOR_AT_0 "$STATUSLINE_PERCENT_COLOR_AT_0" "#08A357" # green
set_color PERCENT_COLOR_AT_50 "$STATUSLINE_PERCENT_COLOR_AT_50" "#D8B400" # yellow
set_color PERCENT_COLOR_AT_100 "$STATUSLINE_PERCENT_COLOR_AT_100" "#EA0000" # red
# ----------------------------------------------------------------------------

input=$(printf '%s' "$(cat)" | tr -d '\r\n')
ESC=$(printf '\033')
RESET="${ESC}[0m"

# Print the first used_percentage value found after the given key, or nothing.
percent_after() {
  case "$input" in
    *"\"$1\""*) ;;
    *) return ;;
  esac
  printf '%s' "$input" \
    | sed "s/.*\"$1\"//" \
    | grep -o '"used_percentage"[[:space:]]*:[[:space:]]*[^,}]*' \
    | head -n 1 \
    | sed 's/.*:[[:space:]]*//; s/\..*//'
}

# Set <prefix>_red, <prefix>_green, and <prefix>_blue to the channels of a "#RRGGBB" color.
# The caller declares those variables local: split_color <color> <prefix>
split_color() {
  local digits=${1#\#}
  printf -v "${2}_red" '%d' "$(( 16#${digits:0:2} ))"
  printf -v "${2}_green" '%d' "$(( 16#${digits:2:2} ))"
  printf -v "${2}_blue" '%d' "$(( 16#${digits:4:2} ))"
}

# Print the 24-bit text color escape for a "#RRGGBB" color, or nothing for the default color.
color_escape() {
  local color_red color_green color_blue
  [ -z "$1" ] && return
  split_color "$1" color
  printf '%s[38;2;%d;%d;%dm' "$ESC" "$color_red" "$color_green" "$color_blue"
}

# Print text wrapped in a color: colorize <text> <color>. Text in the default color gets no escape codes.
colorize() {
  local text=$1 color_code
  color_code=$(color_escape "$2")
  if [ -z "$color_code" ]; then
    printf '%s' "$text"
  else
    printf '%s%s%s' "$color_code" "$text" "$RESET"
  fi
}

# Blend the two nearest gradient targets for a percentage. Prints a "#RRGGBB" color.
percent_color() {
  local percent=$1 start_color end_color distance_from_start
  local start_red start_green start_blue end_red end_green end_blue
  [ "$percent" -lt 0 ] && percent=0
  [ "$percent" -gt 100 ] && percent=100

  # distance_from_start: 0 (start color) to 50 (end color).
  if [ "$percent" -le 50 ]; then
    start_color=$PERCENT_COLOR_AT_0
    end_color=$PERCENT_COLOR_AT_50
    distance_from_start=$percent
  else
    start_color=$PERCENT_COLOR_AT_50
    end_color=$PERCENT_COLOR_AT_100
    distance_from_start=$(( percent - 50 ))
  fi

  split_color "$start_color" start
  split_color "$end_color" end
  printf '#%02X%02X%02X' \
    $(( (start_red * (50 - distance_from_start) + end_red * distance_from_start) / 50 )) \
    $(( (start_green * (50 - distance_from_start) + end_green * distance_from_start) / 50 )) \
    $(( (start_blue * (50 - distance_from_start) + end_blue * distance_from_start) / 50 ))
}

# Thousands separators without relying on locale support.
with_commas() {
  local number=$1 output="" leading_digits
  while [ ${#number} -gt 3 ]; do
    leading_digits=${number%???}
    output=",${number#"$leading_digits"}$output"
    number=$leading_digits
  done
  printf '%s%s' "$number" "$output"
}

token_count=$(printf '%s' "$input" \
  | grep -o '"total_input_tokens"[[:space:]]*:[[:space:]]*[0-9]*' \
  | head -n 1 \
  | sed 's/.*:[[:space:]]*//')
context_percent=$(percent_after context_window)
session_percent=$(percent_after five_hour)
weekly_percent=$(percent_after seven_day)
# effort is absent when the model does not support the effort setting. Empty in that case.
effort_level=$(printf '%s' "$input" \
  | sed -n 's/.*"effort"[[:space:]]*:[[:space:]]*{[^}]*"level"[[:space:]]*:[[:space:]]*"\([a-z]*\)".*/\1/p')

case "$token_count" in ''|null) token_count=0 ;; esac
case "$context_percent" in ''|null) context_percent=0 ;; esac

separator=$(colorize " | " "$SEPARATOR_COLOR")
token_text=$(colorize "$(with_commas "$token_count")" "$TOKEN_COUNT_COLOR")
context_label=$(colorize "Context:" "$CONTEXT_LABEL_COLOR")
context_text=$(colorize "${context_percent}%" "$(percent_color "$context_percent")")
session_label=$(colorize "Session window:" "$SESSION_WINDOW_LABEL_COLOR")
case "$session_percent" in
  ''|null) session_text=$(colorize "--" "$NO_SESSION_DATA_COLOR") ;;
  *) session_text=$(colorize "${session_percent}%" "$(percent_color "$session_percent")") ;;
esac
weekly_label=$(colorize "Weekly limit:" "$WEEKLY_LIMIT_LABEL_COLOR")
case "$weekly_percent" in
  ''|null) weekly_text=$(colorize "--" "$NO_WEEKLY_DATA_COLOR") ;;
  *) weekly_text=$(colorize "${weekly_percent}%" "$(percent_color "$weekly_percent")") ;;
esac

printf '%s%s%s %s%s%s %s%s%s %s' \
  "$token_text" "$separator" \
  "$context_label" "$context_text" "$separator" \
  "$session_label" "$session_text" "$separator" \
  "$weekly_label" "$weekly_text"

if [ -n "$effort_level" ]; then
  printf '%s%s %s' \
    "$separator" \
    "$(colorize "Effort:" "$EFFORT_LABEL_COLOR")" \
    "$(colorize "$effort_level" "$EFFORT_LEVEL_COLOR")"
fi

printf '\n'

