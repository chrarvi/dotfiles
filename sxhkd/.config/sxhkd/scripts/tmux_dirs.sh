dirs=(
        ~/nixos
        ~/.dotfiles
        ~/dotfiles
        ~/.config 
        ~/projects 
        ~/Dropbox/org 
        ~/repos 
        ~/repos/work 
        ~/repos/chrarvi 
        ~/work 
        )


TMUX_DIRS=()

for dir in "${dirs[@]}"; do
  if [[ -d "$dir" ]]; then
    TMUX_DIRS+=("$dir")
  fi
done

