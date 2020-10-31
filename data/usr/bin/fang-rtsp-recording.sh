#!/bin/sh

while :
do
	currentdt=`date -u '+%F_%H%M%S'_UTC`
	log="/media/mmcblk0p2/data/recording_logs/$currentdt.log"
	err_log="/media/mmcblk0p2/data/recording_logs/$currentdt.err"
	record_to="/media/mmcblk0p2/data/recordings_wip/$currentdt.mkv"
	move_to="/media/mmcblk0p2/data/recordings/$currentdt.mkv"

	echo "$currentdt Starting ffmpeg recording..." >> $log

	auth=$(cat /media/mmcblk0p2/data/etc/rtsp.passwd)
	if [ "$auth" ]; then
		echo "$currentdt Starting ffmpeg recording with auth" >> $log
	else
		echo "$currentdt Starting ffmpeg recording without auth" >> $log
	fi

	/media/mmcblk0p2/data/test/ffmpeg/ffmpeg -loglevel warning -i rtsp://$auth@127.0.0.1/unicast -vcodec copy -acodec copy -y -t 300 $record_to > $log 2> $err_log

	if [ "$?" -ne "0" ]; 
	then
		echo "$currentdt Recording with ffmpeg finished with errors, will sleep 10" >> $log
		sleep 10
	else
		echo "$currentdt Recording with ffmpeg finished OK" >> $log
	fi

	mv $record_to $move_to
	echo "$currentdt Moved file from $record_to to $move_to" >> $log
done