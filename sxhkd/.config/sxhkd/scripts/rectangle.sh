#!/usr/bin/env bash
# Script to compute the rectangle string for bspwm.
# The script will fetch the current monitor and provide a centered rectangle with width and height as the argments.
#
# Usage: ./rectangle.sh <width_in_percent> <height_in_percent>

width_coef="$1"
height_coef="$2"
read -r screen_width screen_height x_origin y_origin < <(
  bspc query -m focused -T | jq -r '.rectangle | "\(.width) \(.height) \(.x) \(.y)"'
)
width=$(( width_coef * screen_width / 100 ))
height=$(( height_coef * screen_height / 100 ))
xoffset=$(( x_origin + screen_width / 2 - width / 2 ))
yoffset=$(( y_origin + screen_height / 2 - height / 2 ))

echo "${width}x${height}+${xoffset}+${yoffset}"
