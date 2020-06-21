#!/usr/bin/env bash

printHeading()
{
    title="$1"
    paddingWidth=$((($(tput cols)-${#title})/2-3))
    printf "\n%${paddingWidth}s"|tr ' ' '='
    printf "  $title  "
    printf "%${paddingWidth}s\n\n"|tr ' ' '='
}

showTime()
{
    date '%FT%H:%M%z'
}
