#!/usr/bin/env bash

source $XDG_CONFIG_HOME/sxhkd/scripts/tmux_dirs.sh

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find "${TMUX_DIRS[@]}" -mindepth 0 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    echo "tmux is not running, starting a new tmux session"
    tmux new-session -A -s $selected_name -c $selected
elif [[ -z $TMUX ]] || ! tmux has-session -t=$selected_name 2>/dev/null; then
    echo "No tmux session found, starting a new one."
    tmux new -s $selected_name -c $selected -d
    tmux switch-client -t $selected_name
else
    echo "Switching to existing tmux session."
    tmux switch-client -t $selected_name
fi

