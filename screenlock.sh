#!/bin/bash

killall -9 evtest
/usr/bin/evtest /dev/input/event12 >> /tmp/mousetrack &

while true
do

idlecount=0
idlefail=3

idlecheck () {


idletime=$(/usr/bin/ls -l --time=mtime /tmp/mousetrack | cut -c 27-30 | tr -d ' ')
#3x mouse idle confirmation in 6 minutes to lock the screen
sleep 120
idletime2=$(/usr/sbin/ls -l --time=mtime /tmp/mousetrack | cut -c 27-30 | tr -d ' ')


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

echo $(date +%F_%T) >> /tmp/screenlock_executed && loginctl lock-session $(loginctl list-sessions | cut -c 1-8  | head -n 2 | grep --invert-match "SESSION" | tr -d ' ')

done
