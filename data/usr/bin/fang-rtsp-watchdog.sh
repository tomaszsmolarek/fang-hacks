#!/bin/sh

echo "RTSP Watchdog script started"

while :
do
	sleep 10
	if pgrep -x "snx_rtsp_server" > /dev/null
	then
		echo "RTSP ON - old RTSP server"
	else
		if pgrep -x "/media/mmcblk0p2/data/updates/snx_rtsp_server/usr/bin/snx_rtsp_server" > /dev/null
		then
			echo "RTSP ON - new RTSP server"
		else
			echo "RTSP OFF"
			echo "RTSP Watchdog had to restart snx_rtsp_server "`date` >> /tmp/fang-rtsp-watchdog.log
			/media/mmcblk0p2/data/etc/scripts/20-rtsp-server start > /dev/null
		fi
	fi
done
