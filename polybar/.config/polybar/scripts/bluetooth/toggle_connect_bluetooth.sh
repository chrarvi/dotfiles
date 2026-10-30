#!/usr/bin/env bash

controllers=`bluetoothctl list`
declare -A paired=(
    [MID]="2C:4D:79:10:65:F0"
    [WH-1000XM3]="CC:98:8B:B6:A5:5C"
)
read -ra CON <<< "$controllers"

name=`bluetoothctl info ${DEV[1]}| grep "Name" | sed 's/^.*: //'`
onoff=`bluetoothctl show | grep "Powered" | sed 's/^.*: //'`
connected=`bluetoothctl info | grep "Connected" | sed 's/^.*: //'`
rfkill unblock bluetooth

if [ $onoff == "no" ]
then
    bluetoothctl power on
fi

if [ "$connected" == "yes" ]
then
    bluetoothctl disconnect
else
    bluetoothctl connect ${paired[$1]}
fi
