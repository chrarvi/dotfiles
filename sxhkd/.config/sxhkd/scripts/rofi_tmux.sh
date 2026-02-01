#!/usr/bin/env bash

:<<doc
This is a bash script that launches a Rofi prompt to allow the
user to select an existing or new tmux session to attach to in a new
terminal window. If the selected session is existing, the script
attaches to it; otherwise, it loads a tmuxp layout.

Usage:
./rofi-tmux.sh

The script performs the following steps:

    Reads all open tmux sessions and generates a list of session names.
    Reads all tmuxp layouts to the session list under a (new) name.
    Launches a Rofi prompt to allow the user to select a tmux session.
    - If the user selects an existing session, the script attaches to it in a new terminal window.
    - If the user selects a new session, the script loads up a tmuxp layout with that name.
    - If the user selects a remote session, the script loads up the "workspace" tmux session on the remote ssh target.

The script uses the following external tools:

    tmux (to list and handle sessions)
    tmuxp (to list and load layouts)
    rofi (to prompt the user for a session selection)
    term (to launch new terminal windows)
    ssh
doc

# Read open tmux sessions and generate a list of session names
sessions=$(tmux list-sessions -F "#S" 2>/dev/null)
layouts=$(tmuxp ls)
remotes=$(grep -P "^Host ([^*]+)$" $HOME/.ssh/config | sed 's/Host //')

# Add the layouts
while read layout; do
    if [[ ! "${sessions[*]}" =~ "$layout" ]]; then
        sessions+="\n$layout (new)"
    fi
done <<< "$layouts"

# Add the remotes
while read remote; do
    sessions+="\n$remote (remote)"
done <<< "$remotes"

# Launch Rofi and prompt the user to select a session
selected_session=$(echo -e "$sessions" | rofi -dmenu -p "Select a tmux session")

# Check if the user selected a session
if [[ -n "$selected_session" ]]; then
    name=${selected_session% (new)}
    if [[ "$selected_session" =~ "(remote)" ]]; then
        remote_name=${selected_session% (remote)}
        # TODO: Make this request the sessions over ssh!
        session_name="workspace"
        st -e ssh -A -t $remote_name tmux new-session -A -s $session_name &
    elif [[ "$name" =~ "$selected_session" ]]; then
        # Attach to the selected tmux session in a new terminal window
        st -e tmux new-session -A -s "$selected_session" &
    else
        # Load up tmuxp layout
        session_name=${selected_session% (new)}
        st -e tmuxp load $name --yes &
    fi
fi
