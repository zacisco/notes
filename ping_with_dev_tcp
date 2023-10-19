#!/bin/bash

PS3="Select action: "

prep() {
    echo
    read -p "Enter ADDRESS: " addr;
    read -p "Enter PORT: " port;
    read -p "Enter TIMEOUT: " timeout;
    check tcp $addr $port $timeout
}

check() {
    [ -z "$4" ] && to=1 || to=$4
    timeout $to bash -c "&> /dev/null > /dev/$1/$2/$3 && [ $? -eq 0 ] && echo -e \"Result: \e[32mSUCCESS\e[0m\n\" || echo -e \"Result: \e[31mUNAVAILABLE\e[0m\n\""
}

menu_points=("Run check access" "Exit")
select point in "${menu_points[@]}"; do
    case $REPLY in
        1) prep ;;
        2) break ;;
        *) echo -e "Wrong select, try again.\n" >&2
    esac
    REPLY=
done

exit $?
