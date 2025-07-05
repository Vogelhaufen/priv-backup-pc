#!/bin/bash
killall -9 evtest
sleep 1

# Run evtest for a brief moment and capture the output
/usr/bin/evtest > /tmp/evtestoutput 2>&1 & sleep 1; killall evtest

# Now extract the device name correctly
asdf=$(grep "Logitech G502 HERO Gaming Mouse" /tmp/evtestoutput | grep --invert-match "Keyboard" | cut -f1 -d":")

/usr/bin/evtest $asdf >> /tmp/mousetrack &

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
