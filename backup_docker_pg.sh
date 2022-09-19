#!/bin/bash

help() {
    echo -e "
\e[1mNAME\e[0m
    $0 - backup pg database in docker container

\e[1mSYNOPSIS\e[0m
    $0 [\e[4mOPTIONS\e[0m]... ARGUMENT

\e[1mDESCRIPTION\e[0m
    Script running postgres backup with pg_dump in docker container, archive the result
    and move it in backup directory.

\e[1mOPTIONS\e[0m
    -d, --backup_dir
        name of backup directory (\e[4mpg_backup\e[0m by default)

    -u, --user
        user of database (\e[4mpostgres\e[0m by default)

    -b, --database
        database name (\e[4mpostgres\e[0m by default)

    -s, --schemes
        schemes for backup (\e[4mall\e[0m by default). Example: dictionary,service1,other

    -c, --telegram_channel
        telegram channel id, if set - send message to channel

    -t, --telegram_token
        your telegram bot token for send messages

    -r, --remove
        number of days for cleaning old backups (\e[4m14\e[0m by default)

    -h, --help
        show this HELP

\e[1mARGUMENTS\e[0m
    container name or container id where running POSTGRES database
"
    exit 2
}

send_msg() {
    if [ $sentBotMsg -eq 1 ]
    then
        curl -X POST -s -o /dev/null -d chat_id=$tChatId -d text="$1" $tBotUrl
    fi
}

# ==============================================================================================================
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# ==============================================================================================================

# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# ${PIPESTATUS[0]} with a simple $?, but I prefer safety.
set -o errexit -o pipefail -o noclobber -o nounset

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

# ==============================================================================================================

# options with : requires 1 argument
LONGOPTS=backup_dir:,user:,database:,schemes:,telegram_channel:,telegram_token:,remove:,help
OPTIONS=d:,u:,b:,s:,c:,t:,r:,h

# ==============================================================================================================

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"


backup_dir=pg_backups
user=postgres
db=postgres
schemes="all"
tBotChatId=""
tBotToken=""
tBotUrl="https://api.telegram.org/bot$tBotToken/sendMessage"
cleanOldDay=14
sentBotMsg=0

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -d|--dir)
            backup_dir="$2"
            shift 2
            ;;
        -u|--user)
            user="$2"
            shift 2
            ;;
        -b|--database)
            db="$2"
            shift 2
            ;;
        -s|--schemes)
            schemes="$2"
            shift 2
            ;;
        -c|--telegram_channel)
            tBotChatId="$2"
            shift 2
            ;;
        -t|--telegram_token)
            tBotToken="$2"
            shift 2
            ;;
        -r|--remove)
            cleanOldDay=$2
            shift 2
            ;;
        -h|--help)
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

# handle non-option arguments
if [[ $# -ne 1 ]]; then
    echo "$0: Container id or name is required."
    help
    exit 4
fi

# ==============================================================================================================

container=$1

[ -z "$container" ] && echo -e "Container not found" && exit 0

readarray -td, schemes <<< "$schemes,";
unset 'schemes[-1]';

[ ! -z "$tBotChatId" -a ! -z "$tBotToken" ] && sentBotMsg=1

[ ! -d $backup_dir ] && mkdir $backup_dir
cd $backup_dir
workDir=`pwd`

echo "Cleaning old dumps"
find . -name '*.sql.gz' -mtime +$cleanOldDay -exec rm {} \;

send_msg "PG Dev Dump Start"

for cur in ${schemes[@]}
do
    if [ "$cur" != "all" ]
    then
        cmd="-n $cur "
    fi

    echo "Backup $cur"
    docker exec -i $container pg_dump $cmd-U $user $db | gzip > $workDir/${cur}_$(date +'%Y-%m-%d_%H-%M').sql.gz
done

send_msg "PG Dev Dump DONE"

exit $?
