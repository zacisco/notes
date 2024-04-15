#!/bin/bash

##############################################
# https://github.com/yt-dlp/yt-dlp
##############################################


dir=$HOME
if [ -d "$dir/Downloads" ]; then
    dir+="/Downloads"
elif [ -d "$dir/Загрузки" ]; then
    dir+="/Загрузки"
else
    dir=$PWD
fi

clear

show_options() {
    clear

    [ -z "$url" ] && echo -e "Can't get download options without URL" && return

    yt-dlp -F --list-formats $url
}

show_selected() {
    echo -e "Selected Video ID: $vid"
    echo -e "Selected Audio ID: $aid"
}

set_options() {
    read -p "Enter Video ID: " vid
    read -p "Enter Audio ID: " aid
}

dwnld() {
    clear

    [ -z "$url" ] && echo -e "Can't download without URL" && return
    [ -z "$vid" -a -z "$aid" ] && echo -e "Can't download without video or audio ID" && return

    [ -n "$vid" ] && CMD_OPTS+="$vid"
    if [ -n "$aid" ]; then
        if [ -n "$CMD_OPTS" ]; then
            CMD_OPTS+="+"
        fi
        CMD_OPTS+="$aid"
    fi
    CMD_OPTS+=" $url"

    yt-dlp -f $CMD_OPTS -o "$dir/%(title)s.%(ext)s"
}

menu_points=("SET YouTube url" "SHOW allowed options" "SET options for download" "SHOW options for download" "DOWNLOAD" "Update YT-DLP" "Exit")
select point in "${menu_points[@]}"; do
    case $REPLY in
        1) read -p "Enter YT url: " url && show_options && echo ;;
        2) show_options && echo ;;
        3) set_options && echo ;;
        4) show_selected && echo ;;
        5) dwnld && echo ;;
        6) clear && sudo yt-dlp -U ;;
        7) break ;;
        *) echo -e "Wrong select, try again.\n" >&2 ;;
    esac
    REPLY=
done

exit $?
