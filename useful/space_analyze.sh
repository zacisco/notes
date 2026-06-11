#!/usr/bin/env bash

echo

read -s -p "Password: " pass

tmp_file=$(mktemp)

analyze() {
    sudo -S du --time -h -d 1 $1 2>/dev/null <<< $pass > $tmp_file
    echo -e "Total dir info: \n$(cat $tmp_file | tail -n 1)\n"
    cat $tmp_file | head -n -1 | sort -hr
    welcome
}

welcome() {
    echo
    read -ep "Enter path for analyze: " aDir
    [ -z "$aDir" ] && rm -rf $tmp_file && exit 0
    analyze $aDir
}

welcome

exit $?
