#!/bin/sh

echo "IR script started"
: > /tmp/dark_image_detection.log # truncate the file

# ir_init
#gpio_ms1 -n 2 -m 1 -v 1 # this causes increased current flow
gpio_ms1 -n 2 -m 1 -v 0 # has something to do with the ir-cut/pass filter movement
gpio_aud write 1 1 0    # pin 1 is an output and is set to low, purpose unknown
gpio_aud write 0 2 1    # pin 2 is an input, the photoresistor
gpio_aud write 1 0 0    # pin 0 is an output and set to low, these are the ir-leds

sleep 3

# ir loop
IR_ON=0

while :
do
        DAY="$(gpio_aud read 2)"
        if [ $DAY -eq 1 ]
        then
                if [ $IR_ON -eq 1 ]
                then
                        gpio_ms1 -n 2 -m 1 -v 1 # filter movement enabled
                        gpio_aud write 1 0 0    # disable ir led and latch the filter in the correct position
                        gpio_ms1 -n 2 -m 1 -v 0 # filter movement disabled
                        echo 0x40 > /proc/isp/filter/saturation
                        IR_ON=0
                fi
        else
                if [ $IR_ON -eq 0 ]
                then
                        echo 0x0 > /proc/isp/filter/saturation
                        gpio_ms1 -n 2 -m 1 -v 0 # filter movement enabled
                        gpio_aud write 1 0 1    # enable ir led and latch the filter in the correct position
                        gpio_ms1 -n 2 -m 1 -v 1 # filter movement disabled
                        IR_ON=1
                else
                        # Night, IR on, let's detect too dark images
                        # Sometimes if there's night mode on and it gets darker and darker very slowly, the camera won't adjust and will end up showing a very dark (almost black) image
                        CURRENTDT=`date -u '+%F_%H%M%S'_UTC`

                        auth=$(cat /media/mmcblk0p2/data/etc/rtsp.passwd)
                        if [ "$auth" ]; then
                                auth_param="${auth}@"
                        else
                                auth_param=""
                        fi

                        # https://stackoverflow.com/questions/58971875
                        # params? tested some, seems like 3 sec is enough (iframe every 2 sec in 20-rtsp-server) and level of 0.4 will do it...
                        IS_DARK_IMAGE=$(/media/mmcblk0p2/data/test/ffmpeg/ffmpeg -t 3 -loglevel info -i rtsp://${auth_param}127.0.0.1/unicast -vf blackdetect=d=0.1:pix_th=0.4 -f rawvideo -y /dev/null -vsync 2 2>&1 | grep black_duration | wc -l)
                        # echo "$CURRENTDT detected: $IS_DARK_IMAGE ..." >> /tmp/dark_image_detection.log

                        if [ $IS_DARK_IMAGE -eq 0 ]
                        then
                                # echo "$CURRENTDT ... image is OK, no action needed" >> /tmp/dark_image_detection.log
                                IS_DARK_IMAGE = 0 # Can't have empty clause https://unix.stackexchange.com/a/134025
                        else
                                echo "$CURRENTDT ... image is TOO DARK, will try resetting IR and color" >> /tmp/dark_image_detection.log

                                echo 0x0 > /proc/isp/filter/saturation 2>&1 >> /tmp/dark_image_detection.log
                                sleep 1
                                gpio_ms1 -n 2 -m 1 -v 0 2>&1 >> /tmp/dark_image_detection.log
                                sleep 1
                                gpio_aud write 1 0 1 2>&1 >> /tmp/dark_image_detection.log
                                sleep 1
                                gpio_ms1 -n 2 -m 1 -v 1 2>&1 >> /tmp/dark_image_detection.log
                                sleep 1

                                echo "$CURRENTDT reset done, all should be good now" >> /tmp/dark_image_detection.log

                                sleep 10
                        fi
                fi
        fi
        sleep 10
done
