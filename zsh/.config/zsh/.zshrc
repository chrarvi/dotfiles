exist() {
    command -v "$1" >/dev/null 2>&1
}

export PATH=$HOME/go/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export EDITOR=nvim
export HISTFILE="${XDG_CONFIG_HOME}/zsh/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt EXTENDED_HISTORY INC_APPEND_HISTORY_TIME HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

ZVM_INIT_MODE=sourcing  # initialize instantly on source
source $HOME/.zsh/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

# Cache the completion initialization to 24h age
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qNmh-24) ]]; then
  compinit -C
else
  compinit
fi
source $HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh

# ssh agent
if ! pgrep ssh-agent > /dev/null; then
    # use: `systemctl --user enable --now ssh-agent.socket`
    # which is included in `openssh-9.4p1-3`
    # or the dinit service in `dinit/.config/dinit.d/ssh-agent`
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

exist zoxide && eval "$(zoxide init zsh)"

if exist fzf; then
    source <(fzf --zsh)
    bindkey '^r' fzf-history-widget
fi

if exist tmux; then
    alias ts="~/.config/scripts/tmux_sessionizer.sh"
    tmux_sessionizer() {
        BUFFER="~/.config/scripts/tmux_sessionizer.sh"
        zle accept-line
    }
    zle -N tmux_sessionizer
    bindkey -r '^F'
    bindkey -M viins '^F' tmux_sessionizer
    bindkey -M vicmd '^F' tmux_sessionizer
fi

if command -v pyenv >/dev/null 2>&1; then
    pyenv() {
        unset -f pyenv

        eval "$(command pyenv init -)"
        eval "$(command pyenv virtualenv-init -)"

        pyenv "$@"
    }
fi

exist emacsclient && alias em="emacsclient -s null -nw ./"
exist feh && alias feh="feh --draw-filename -B 'black' --scale-down -R 5"

# Source work config file if it exists
work_config_file="$HOME/.config/shell_work/work.zsh"
if [ -f "$work_config_file" ]; then
    source "$work_config_file"
fi
