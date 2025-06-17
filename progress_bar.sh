#!/usr/bin/env bash

# Progress Bar Options
bar_size=40
bar_char_done="#"
bar_char_left=" "
bar_percentage_scale=0

function show_progress {
  current="$1"
  total="$2"
  add_text="$3"
  percent=$(( 100 * current / total ))
  done=$(( bar_size * percent / 100 ))
  left=$(( bar_size - done ))
  done_sub_bar=$(printf "%${done}s" | tr " " "${bar_char_done}")
  left_sub_bar=$(printf "%${left}s" | tr " " "${bar_char_left}")
  echo -ne "\rProgress : [${done_sub_bar}${left_sub_bar}] ${percent}% ${add_text}"
}
