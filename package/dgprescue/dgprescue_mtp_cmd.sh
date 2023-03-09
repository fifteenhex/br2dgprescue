#!/bin/sh

#set -x

while true; do
    echo "Waiting for a cmd to be created..."

    EVENT=`inotifywait -e create -q /run/dgprescue/cmd/`
    FILE=`echo $EVENT | cut -d " " -f 3`;

    case "$FILE" in
        reboot)
            echo "Triggering reboot"
            reboot
            ;;
        *)
            echo "I have no idea what $FILE is"
            ;;
    esac
done
