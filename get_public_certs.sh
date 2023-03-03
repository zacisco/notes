#!/bin/bash

[ -z "$1" ] && echo -e "\nUsage: ${basename $0} address" && exit 0

REMOTE_HOST=$1

echo \
    | openssl s_client -showcerts -partial_chain -servername ${REMOTE_HOST} -connect ${REMOTE_HOST}:443 \
    | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="'"${REMOTE_HOST}"'"a".pem"; print >out}'

exit $?
