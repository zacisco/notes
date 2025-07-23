#!/usr/bin/env bash

label="Progress: "

# Percent Progress Bar Options
bar_size=40
bar_char_done="#"
bar_char_left=" "
bar_percentage_scale=0

show_percent_progress() {
  local current=${1}
  local total=${2}
  local add_text="${3}"
  [ ! -z "${4}" ] && label="${4}"

  local percent=$(( 100 * current / total ))
  local done=$(( bar_size * percent / 100 ))
  local left=$(( bar_size - done ))
  local done_sub_bar=$(printf "%${done}s" | tr " " "${bar_char_done}")
  local left_sub_bar=$(printf "%${left}s" | tr " " "${bar_char_left}")

  echo -ne "\r${label}[${done_sub_bar}${left_sub_bar}] ${percent}% ${add_text}"
}

# Spinner Progress Bar Options
spinner_chars="/-\|"

show_spinner_progress() {
  local progress=$(( ($1+1) %4 ))
  [ ! -z "${2}" ] && label="${2}"

  echo -ne "\r${label}${spinner_chars:$progress:1}"
}

# Countdown timer Options
add_text=" left"

countdown_timer() {
    local seconds=$1
    [ ! -z "${2}" ] && label="${2}"
    [ ! -z "${3}" ] && add_text="${3}"
    while [ $seconds -ge 0 ]; do
        local h=$(( seconds / 3600 ))
        local m=$(( (seconds % 3600) / 60 ))
        local s=$(( seconds % 60 ))
        printf "\r%s%02d:%02d:%02d%s" $label $h $m $s $add_text
        sleep 1
        seconds=$(( seconds - 1 ))
    done
}
