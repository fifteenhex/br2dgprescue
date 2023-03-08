#!/bin/sh

inotifywait -q -m /run/dgprescue/fw/* | while read -r EVENT;
do
    DIR=`echo $EVENT | cut -d " " -f 1`;
    TARGET=`basename $DIR`;
    TYPE=`echo $EVENT | cut -d " " -f 2`;
    FILE=`echo $EVENT | cut -d " " -f 3`;
    #echo dbg $TARGET $TYPE $FILE;
    case "$TYPE" in
        "OPEN")
            echo "User is uploading firmware? File called $FILE"
        ;;
        "MODIFY")
        ;;
        "CLOSE_NOWRITE,CLOSE")
            echo "Nope, they were just poking around"
        ;;
        "CLOSE_WRITE,CLOSE")
            # Close write should indicate that we have a file to use
            echo "Write close for $FILE, lets check this out!"
            FILE_PATH=$DIR/$FILE

            # Check the file is still there..
            if [ ! -f $DIR/$FILE ]; then
                echo "File disappeared.."
                continue
            fi

            # Quickly move the file so somewhere MTP can't see it
            UPDATE_FILE=/tmp/$FILE
            echo "moving the file..."
            mv $FILE_PATH $UPDATE_FILE
            
            # If the file size is 0 we ignore it.
            SIZE=`du -b $UPDATE_FILE | cut -f 1`
            if [ $SIZE -eq 0 ]; then
                echo "eh, file size is zero, probably shouldn't try to write this.."
                continue
            fi
            
            sha256sum $UPDATE_FILE
            
            # See if mkimage thinks it's a FIT
            mkimage -q -T flat_dt -l $UPDATE_FILE
            if [ $? -ne 0 ]; then
                echo "mm doesn't look like a FIT? not touching this.."
                continue
            fi
            
            # Lets do this..
            echo "Hold on to your pants! writing image"
            ubiupdatevol /dev/ubi0_3 $UPDATE_FILE
        ;;
    esac
done
