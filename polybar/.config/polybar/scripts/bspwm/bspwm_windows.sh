#!/usr/bin/env bash

# Define an associative array for program icons
declare -A program_icons
program_icons["firefox"]=""
program_icons["firefox-bin"]=""
program_icons["code"]=""
program_icons["emacs"]=""
program_icons["terminal"]=""
program_icons["kitty"]=""
program_icons["st"]=""
program_icons["alacritty"]=""
program_icons["qutebrowser"]="qb"
program_icons["DiscordCanary"]=""
program_icons["slack"]=""
program_icons["spotify"]=""
program_icons["zathura"]=""
program_icons["sioyek"]=""
program_icons["teams-for-linux"]=""

# Get the node IDs of all windows in the focused desktop
nodes=$(bspc query -N -n .window -d focused -m focused)

# Get the focused window ID
focused_window=$(bspc query -N -n focused)

if [ -n "$focused_window" ]; then
    # Get the PID of the currently focused window
    current_pid=$(xprop -id "$focused_window" _NET_WM_PID | awk '{print $3}')
    current_program=$(ps -o comm= -p "$current_pid")
else
    current_program="No focused window"
    echo ""
    exit 0
fi

# Formatting
b_sel="%{+u}%{u#e1986d}"
e_sel="%{-u}"

# Loop over each node to get program names
echo "$nodes" | while IFS= read -r node; do
    # Get the PID of the current node
    pid=$(xprop -id "$node" _NET_WM_PID | awk '{print $3}')

    if [ -n "$pid" ]; then
        # Get the program name associated with the PID
        program=$(ps -o comm= -p "$pid")

        # Check if the current node corresponds to the focused window
        if [ "$pid" = "$current_pid" ]; then
            # Print the program name with a marker and icon to indicate the currently focused window
            echo -n " $b_sel${program_icons[$program]:-$program}$e_sel"
        else
            # Print the program name with an icon if available, otherwise just the program name
            echo -n " ${program_icons[$program]:-$program}"
        fi
        echo -n " "
    fi
done

# Print a message if there is no focused window
if [ "$current_program" = "No focused window" ]; then
    echo " $current_program"
fi
