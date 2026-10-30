#!/usr/bin/env sh

MAC=$(bluetoothctl devices Connected | awk 'NR == 1 {print $2}')

if [ -z "$MAC" ]; then
    echo "on"
    exit 0
fi

name=$(bluetoothctl info "$MAC" |
    awk -F': ' '/^[[:space:]]*Name:/ {print $2; exit}')

onoff=$(bluetoothctl show |
    awk -F': ' '/^[[:space:]]*Powered:/ {print $2; exit}')

if [ "$onoff" = "yes" ]; then
    if [ -z "$name" ]; then
        echo "on"
    else
        echo "$name"
    fi
else
    echo ""
fi

