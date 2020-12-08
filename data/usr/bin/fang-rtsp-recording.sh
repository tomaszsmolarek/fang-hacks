#!/bin/sh

while :
do
	CURRENTDT=`date -u '+%F_%H%M%S'_UTC`
	CURRENTD=`date -u '+%F'_UTC`
	LOGS_FOLDER_BASE="/media/mmcblk0p2/data/recordings_logs/"
	LOGS_FOLDER="$LOGS_FOLDER_BASE$CURRENTD/"
	LOG="$LOGS_FOLDER$CURRENTDT.log"
	REC_LOG="$LOGS_FOLDER$CURRENTDT-rec.log"
	REC_ERR_LOG="$LOGS_FOLDER$CURRENTDT-rec.err"
	RECORD_FOLDER="/media/mmcblk0p2/data/recordings_wip/"
	RECORD_TO="$RECORD_FOLDER$CURRENTDT.mkv"
	DEST_FOLDER="/media/mmcblk0p2/data/recordings/"
	DEST_TO="$DEST_FOLDER$CURRENTDT.mkv"	

	RECORDING_TIME_SEC=300
	OLD_FILES_PURGE_DAYS=14
	HDD_SPACE_THRESHOLD_KB=204800

	echo "$CURRENTDT Will remove empty folders from $LOGS_FOLDER_BASE and $RECORD_FOLDER and $DEST_FOLDER" >> $LOG 
	find $LOGS_FOLDER_BASE -type d -exec rmdir {} + 2>/dev/null
	find $RECORD_FOLDER -type d -exec rmdir {} + 2>/dev/null
	find $DEST_FOLDER -type d -exec rmdir {} + 2>/dev/null

	mkdir -p $LOGS_FOLDER
	mkdir -p $RECORD_FOLDER
	mkdir -p $DEST_FOLDER
	touch $LOG
	touch $REC_LOG
	touch $REC_ERR_LOG

	echo "$CURRENTDT Will move all incomplete recordings from $RECORD_FOLDER to $DEST_FOLDER" >> $LOG 
	tmp_move_src="$RECORD_FOLDER*"
	mv $tmp_move_src $DEST_FOLDER >> $LOG 2>/dev/null

	echo "$CURRENTDT Will remove files older than $OLD_FILES_PURGE_DAYS days from $LOGS_FOLDER_BASE" >> $LOG 
	find $LOGS_FOLDER_BASE -mtime +$OLD_FILES_PURGE_DAYS -type f -print >> $LOG 2>&1
	find $LOGS_FOLDER_BASE -mtime +$OLD_FILES_PURGE_DAYS -type f -exec rm {} \; >> $LOG 2>&1

	echo "$CURRENTDT Will remove files older than $OLD_FILES_PURGE_DAYS days from $DEST_FOLDER" >> $LOG 
	find $DEST_FOLDER -mtime +$OLD_FILES_PURGE_DAYS -type f -print >> $LOG 2>&1
	find $DEST_FOLDER -mtime +$OLD_FILES_PURGE_DAYS -type f -exec rm {} \; >> $LOG 2>&1

	FREE_SDCARD_SPACE_KB=`df /dev/mmcblk0p2 | tail -n 1 | awk '{print $4}'`

	while [ "$FREE_SDCARD_SPACE_KB" -le "$HDD_SPACE_THRESHOLD_KB" ]; do
		echo "$CURRENTDT There's not enough space on SD CARD! Free space is $FREE_SDCARD_SPACE_KB KB, need $HDD_SPACE_THRESHOLD_KB KB" >> $LOG
		OLDEST_FILE=`ls -1t $DEST_FOLDER | tail -1`
		echo "$CURRENTDT Will delete oldest file ($DEST_FOLDER$OLDEST_FILE) and retry" >> $LOG
		rm -f $DEST_FOLDER$OLDEST_FILE >> $LOG 2>&1
		FREE_SDCARD_SPACE_KB=`df /dev/mmcblk0p2 | tail -n 1 | awk '{print $4}'`
	done

	auth=$(cat /media/mmcblk0p2/data/etc/rtsp.passwd)
	if [ "$auth" ]; then
		echo "$CURRENTDT Starting ffmpeg recording with auth" >> $LOG
		/media/mmcblk0p2/data/test/ffmpeg/ffmpeg -loglevel warning -i rtsp://$auth@127.0.0.1/unicast -vcodec copy -acodec copy -y -t $RECORDING_TIME_SEC $RECORD_TO >> $REC_LOG 2>> $REC_ERR_LOG
	else
		echo "$CURRENTDT Starting ffmpeg recording without auth" >> $LOG
		/media/mmcblk0p2/data/test/ffmpeg/ffmpeg -loglevel warning -i rtsp://127.0.0.1/unicast -vcodec copy -acodec copy -y -t $RECORDING_TIME_SEC $RECORD_TO >> $REC_LOG 2>> $REC_ERR_LOG
	fi

	if [ "$?" -ne "0" ]; 
	then
		echo "$CURRENTDT Recording with ffmpeg finished with ERRORS, will sleep 10 and continue" >> $LOG
		sleep 10
	else
		echo "$CURRENTDT Recording with ffmpeg finished OK" >> $LOG
	fi

	mv $RECORD_TO $DEST_TO
	echo "$CURRENTDT Moved file from $RECORD_TO to $DEST_TO" >> $LOG

done