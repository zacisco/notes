#!/usr/bin/env bash

label="Progress: "

# Percent Progress Bar Options
bar_size=40
bar_char_done="#"
bar_char_left=" "
bar_percentage_scale=0

show_percent_progress() {
  current="$1"
  total="$2"
  add_text="$3"
  [ ! -z "$4" ] && label="$4"

  percent=$(( 100 * current / total ))
  done=$(( bar_size * percent / 100 ))
  left=$(( bar_size - done ))
  done_sub_bar=$(printf "%${done}s" | tr " " "${bar_char_done}")
  left_sub_bar=$(printf "%${left}s" | tr " " "${bar_char_left}")

  echo -ne "\r${label}[${done_sub_bar}${left_sub_bar}] ${percent}% ${add_text}"
}

# Spinner Progress Bar Options
spinner_chars="/-\|"

show_spinner_progress() {
  local progress=$(( ($1+1) %4 ))
  [ ! -z "$2" ] && label="$2"
  [ -z "${add_text}" ] && add_text="Progress:"

  echo -ne "\r${label}${spinner_chars:$progress:1}"
}
