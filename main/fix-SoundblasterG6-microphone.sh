#!/usr/bin/env bash
#sleep 45
#sudo usbreset 041e:3256


cardNumber=$(aplay -l|grep 'Sound BlasterX G6'|cut -d' ' -f 2 |tr -d ':')
amixer -c "$cardNumber" -q set "PCM Capture Source" "External Mic"
sleep 2
amixer -c "$cardNumber" -q set "PCM Capture Source" "S/PDIF In"
sleep 2
amixer -c "$cardNumber" -q set "PCM Capture Source" "External Mic"
