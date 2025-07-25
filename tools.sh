#!/usr/bin/env bash

# check by NUM from here: https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash

# if Unsigned Integer > $? return 0
is_uint() {
  case $1 in
    ''|*[!0-9]*) return 1;;
  esac
}

# if Signed Integer > $? return 0
is_int() {
  case ${1#[-+]} in
    ''|*[!0-9]*) return 1;;
  esac
}

# if Number (float) > $? return 0
is_num() {
  case ${1#[-+]} in
    ''|.|*[!0-9.]*|*.*.*) return 1;;
  esac
}

# get version from build.gradle or gradle.properties (can add prefixes)
gen_app_version() {
  local read_only=$1
  local build_type=$2
  local ver_suffix=$3
  # Prepare archive version suffix
  local app_ver=$(grep -E "^version" build.gradle | sed -r "s|^version .*?'(.*?)'|\1|")
  [ -z "${app_ver}" ] && app_ver=$(grep -E "^version" gradle.properties | sed -r "s/^version=//")
  if [ -z "${read_only}" ]; then
    [ "${build_type}" = "test" ] && app_ver+="_TEST"
    [ ! -z "${ver_suffix}" ] && app_ver+="_${ver_suffix}"
  fi
  echo $app_ver
} 

check_and_get() {
  local branch_or_tag="${1}"
  local clone_url="${2}"
  local cmd_file="${3}"
  local simple="${4}"
  [ ! -z "${simple}" ] && local git_args="--depth=1"
  if [ ! -f "${cmd_file}" ]; then
    git -c advice.detachedHead=false clone $git_args --branch=$branch_or_tag $clone_url
    cd $(get_single_folder .) && chmod +x $cmd_file && echo
  else
    chmod +x $cmd_file
  fi
}

check_curl_status() {
  local val=$1
  local stage="${2}"
  local file="${3}"
  is_uint $val
  [ $? -eq 0 ] && [ $val -ne 200 ] && echo "${stage} ERROR. Look at ${file}" && exit
}

get_single_folder() {
  echo $(find "${1}" -mindepth 1 -maxdepth 1 -type d)
}

make_dir() {
  [ ! -d "${1}" ] && mkdir -p $1 && echo -e "${Yellow}Директория ${1} была создана${Color_Off}"
}

clear_dir() {
  [ -d "${1}" ] && [ "$(ls -A "${1}")" ] && echo -e "${Yellow}Очистка директории ${1}${Color_Off}" && rm -rf $1/* $1/.[!.]* $1/..?*
}
