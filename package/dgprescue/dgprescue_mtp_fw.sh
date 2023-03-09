#!/bin/sh

#set -x

while true; do
    echo "Waiting for a file to be written..."

    # inotifywait can give weird sequences of events
    # so we wait for a single close_write instead of
    # of using the monitor mode.
    EVENT=`inotifywait -e close_write -q /run/dgprescue/fw/*`
    DIR=`echo $EVENT | cut -d " " -f 1`;
    TARGET=`basename $DIR`;
    FILE=`echo $EVENT | cut -d " " -f 3`;
    #echo dbg $TARGET $FILE;

    # Close write should indicate that we have a file to use
    echo "Write close for $FILE, lets check this out!"
    FILE_PATH=$DIR/$FILE

    # Check the file is still there..
    if [ ! -f $FILE_PATH ]; then
        echo "File disappeared.."
        continue
    fi
    
    # Wait for a while...
    for i in `seq 10`; do
        sleep 1
    done

    # Move the file out of MTP
    UPDATE_FILE=/tmp/$FILE
    mv $FILE_PATH $UPDATE_FILE

    # See if mkimage thinks it's a FIT
    mkimage -q -T flat_dt -l $UPDATE_FILE
    if [ $? -ne 0 ]; then
        echo "mm doesn't look like a FIT? not touching this.."
    fi
    
    # Lets do this..
    for VOL in /sys/class/ubi/ubi0_*; do
        VOLNAME=`cat $VOL/name`
        if [ "$VOLNAME" == "$TARGET" ]; then
            break
        fi
    done
    VOL=`basename $VOL`
    
    echo "Hold on to your pants! writing image to $VOL"
    ubiupdatevol /dev/$VOL $UPDATE_FILE

    echo "Done!"
done
