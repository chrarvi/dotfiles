#!/usr/bin/env bash

# notify-send -u low "autorandr: restarting polybar"

# Wait until the processes have been shut down
while pgrep -u "$(id -u)" -x polybar >/dev/null; do
    killall -s SIGKILL polybar
    sleep 0.1
done

host=$(hostname -s)

# Select the bar configuration based on the hostname
case "$host" in
    shuttle)
        primary_bar="shuttle-topbar"
        ;;
    u5cg4373yhk)
        primary_bar="work-topbar"
        ;;
    station)
        primary_bar="station-topbar"
        ;;
    *)
        echo "Unknown hostname: $host" >&2
        exit 1
        ;;
esac

xrandr | grep ' connected' | while read -r line; do
    name=$(awk '{print $1}' <<< "$line")

    if [[ "$line" == *" primary "* ]]; then
        bar="$primary_bar"
    else
        bar="external"
    fi

    # Give bspwm time to set the monitors
    MONITOR="$name" polybar -r "$bar" > /tmp/polybar.log 2>&1 &
done

echo "Bars launched on $host..."

