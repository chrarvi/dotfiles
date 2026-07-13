#!/usr/bin/env bash

set -euo pipefail

source "$XDG_CONFIG_HOME/sxhkd/scripts/tmux_dirs.sh"

if [[ $# -eq 1 ]]; then
    selected="$1"
else
    selected=$(find "${TMUX_DIRS[@]}" -mindepth 0 -maxdepth 1 -type d | fzf)
fi

[[ -z "$selected" ]] && exit 0

selected_name=$(basename "$selected" | tr '.' '_')

if ! tmux has-session -t "$selected_name" 2>/dev/null; then
    echo "Creating new tmux session: $selected_name"
    tmux new-session -d -s "$selected_name" -c "$selected"
fi

if [[ -n "${TMUX:-}" ]]; then
    echo "Switching to session: $selected_name"
    tmux switch-client -t "$selected_name"
else
    echo "Attaching to session: $selected_name"
    exec tmux attach-session -t "$selected_name"
fi


