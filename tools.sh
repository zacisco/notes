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
  ONLY_READ=$1
  BUILD_TYPE=$2
  VER_SUFFIX=$3
  # Prepare archive version suffix
  local app_ver=$(grep -E "^version" build.gradle | sed -r "s|^version .*?'(.*?)'|\1|")
  [ -z "${app_ver}" ] && app_ver=$(grep -E "^version" gradle.properties | sed -r "s/^version=//")
  if [ -z "${ONLY_READ}" ]; then
    [ "${BUILD_TYPE}" = "test" ] && app_ver+="_TEST"
    [ ! -z "${VER_SUFFIX}" ] && app_ver+="_${VER_SUFFIX}"
  fi
  echo $app_ver
}

check_and_get() {
  local simple=$1
  [ ! -z "${simple}" ] && GIT_ARGS="--depth=1"
  if [ ! -f "${CMD_FILE}" ]; then
    git -c advice.detachedHead=false clone $GIT_ARGS --branch=$BRANCH_or_TAG $gitlab
    cd document
    chmod +x $CMD_FILE
    echo
  fi
}

check_curl_status() {
  local val=$1
  local stage=$2
  local file=$3
  is_uint $val
  if [ $? -eq 0 ] && [ $val -ne 200 ]; then
    echo "${stage} ERROR. Look at ${file}" && exit
  fi
}

make_dir() {
  [ ! -d "${1}" ] && mkdir -p $1 && echo -e "${Yellow}Директория ${1} была создана${Color_Off}"
}

clear_dir() {
  [ -d "${1}" ] && [ "$(ls -A "${1}")" ] && echo -e "${Yellow}Очистка директории ${1}${Color_Off}" && rm -rf $1/* $1/.[!.]* $1/..?*
}
