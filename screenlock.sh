#!/bin/bash
#mousetracker for unconitional screen lock on plasma


killall -9 evtest
/usr/bin/evtest /dev/input/event12 >> /tmp/mousetrack &

while true
do

idlecount=0
idlefail=3

idlecheck () {


idletime=$(/usr/bin/ls -l --time=mtime /tmp/mousetrack | cut -c 27-30)
#3x mouse idle confirmation in 6 minutes to lock the screen
sleep 300
idletime2=$(/usr/sbin/ls -l --time=mtime /tmp/mousetrack | cut -c 27-30)


if [ $idletime == $idletime2 ]; then
idlecount=$(($idlecount+1))

if (( $idlecount > $idlefail )); then
idlecount=0
sleep 1
else
idlecheck
fi
else 
idlecheck
fi
}

idlecheck

echo $(date +%F_%T) >> /tmp/screenlock_executed && loginctl lock-session 2>&1 1>/dev/null

done
