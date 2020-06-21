#!/usr/bin/env bash

export TMP_DATA_BASE_DIR="/data/tmp"

printHeading()
{
    title="$1"
    paddingWidth=$((($(tput cols)-${#title})/2-3))
    printf "\n%${paddingWidth}s"|tr ' ' '='
    printf "  $title  "
    printf "%${paddingWidth}s\n\n"|tr ' ' '='
}

validateTime()
{
    if [ "$1" = "" ]
    then
        echo "Time is missing!"
        exit 1
    fi
    TIME=$1
    date -d "$TIME" >/dev/null 2>&1
    if [ "$?" != "0" ]
    then
        echo "Invalid Time: $TIME"
        exit 1
    fi
}
