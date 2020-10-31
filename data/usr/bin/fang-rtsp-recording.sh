#!/bin/sh

while :
do
	currentdt=`date -u '+%F_%H%M%S'_UTC`
	log="/media/mmcblk0p2/data/recordings_logs/$currentdt.log"
	rec_log="/media/mmcblk0p2/data/recordings_logs/$currentdt-rec.log"
	rec_err_log="/media/mmcblk0p2/data/recordings_logs/$currentdt-rec.err"
	record_folder="/media/mmcblk0p2/data/recordings_wip/"
	record_to="$record_folder$currentdt.mkv"
	dest_folder="/media/mmcblk0p2/data/recordings/"
	move_to="$dest_folder$currentdt.mkv"

	touch $log
	touch $rec_log
	touch $rec_err_log

	echo "$currentdt Will move all incomplete recordings from $record_folder to $dest_folder" >> $log 
	tmp_move_src="$record_folder*"
	mv $tmp_move_src $dest_folder

	auth=$(cat /media/mmcblk0p2/data/etc/rtsp.passwd)
	if [ "$auth" ]; then
		echo "$currentdt Starting ffmpeg recording with auth" >> $log
		/media/mmcblk0p2/data/test/ffmpeg/ffmpeg -loglevel warning -i rtsp://$auth@127.0.0.1/unicast -vcodec copy -acodec copy -y -t 300 $record_to >> $rec_log 2>> $rec_err_log
	else
		echo "$currentdt Starting ffmpeg recording without auth" >> $log
		/media/mmcblk0p2/data/test/ffmpeg/ffmpeg -loglevel warning -i rtsp://127.0.0.1/unicast -vcodec copy -acodec copy -y -t 300 $record_to >> $rec_log 2>> $rec_err_log
	fi

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