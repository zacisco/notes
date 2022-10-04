#!/bin/bash

CLIST=""

help() {
    echo "Usage: $0 [-c \"<container>\"]"
    echo ""
    echo "By default, logs for all containers are cleared."
    echo ""
    echo -e "\t-c \"<container>\" Specific container(s) name or docker-compose service(s) name"
    exit 1
}

if [ $# == 0 ]; then
    echo "Clear logs for all containers"
    CLIST="$(docker ps -aq)"
elif [ "$1" == "--" ] || [[ "$1" =~ ^-$ ]] || ! [[ "$1" =~ ^- ]]; then
        help
else
    while getopts "c:" opt; do
        case $opt in
            c) 
                CNAMES+=("$OPTARG")
                echo "Clear logs for \"$CNAMES\"" ;;
            \?) help ;;
        esac
    done
    shift $((OPTIND -1))
    if ! [ "$1" == "" ]; then
        help
    fi
fi

for i in $CNAMES; do
    CONTAINERS=$(docker ps -aq -f name=$i 2> /dev/null)
    if [ "$CONTAINERS" == "" ]; then
        CONTAINERS="$(docker-compose ps -aq $i 2> /dev/null)"
        if [ -z $CONTAINERS ]; then
            echo "Container or service \"$i\" does not exist."
        fi
    fi
    CLIST+=$CONTAINERS$'\n'
done

for i in $CLIST; do
    log=$(docker inspect -f '{{.LogPath}}' $i 2> /dev/null)
    truncate -s 0 $log
done

exit $?
