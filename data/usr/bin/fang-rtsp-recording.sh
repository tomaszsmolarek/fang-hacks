#!/bin/sh

while :
do
	currentdt=`date -u '+%F_%H%M%S'_UTC`

	echo "Starting ffmpeg recording..." >> /media/mmcblk0p2/data/recording_logs/$currentdt.log

	auth=$(cat /media/mmcblk0p2/data/etc/rtsp.passwd)
	if [ "$auth" ]; then
		echo "$currentdt Starting ffmpeg recording with auth" >> /media/mmcblk0p2/data/recording_logs/$currentdt.log
	else
		echo "$currentdt Starting ffmpeg recording without auth" >> /media/mmcblk0p2/data/recording_logs/$currentdt.log
	fi

	/media/mmcblk0p2/data/test/ffmpeg/ffmpeg -loglevel warning -i rtsp://$auth@127.0.0.1/unicast -vcodec copy -acodec copy -y -t 300 /media/mmcblk0p2/data/recordings/$currentdt.mkv > /media/mmcblk0p2/data/recording_logs/$currentdt.log 2> /media/mmcblk0p2/data/recording_logs/$currentdt.err

	if [ "$?" -ne "0" ]; 
	then
		echo "$currentdt Recording with ffmpeg finished with errors, will sleep 10" >> /media/mmcblk0p2/data/recording_logs/$currentdt.log
		sleep 10
	else
		echo "$currentdt Recording with ffmpeg finished OK" >> /media/mmcblk0p2/data/recording_logs/$currentdt.log
	fi
done