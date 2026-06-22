# Eliminates PATH duplicate entries
typeset -U path

# Setup history
# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE="$ZDOTDIR/.zsh_history"

# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug "wintermi/zsh-starship"

# Load and initialise completion system
autoload -Uz compinit
compinit -C

# Fix wrong Home/End/Del/Insert bindings
bindkey -e
bindkey "^[[H" beginning-of-line    # Home key
bindkey "^[[F" end-of-line          # End key
bindkey "^[[2~" overwrite-mode      # Insert key
bindkey "^[[3~" delete-char         # Delete key

# Aliases
alias cs="find \"\$OBSIDIAN_VAULT/Coding/CheatSheets\" -type f -name '*.md' \
  | fzf --preview 'bat --style=numbers --color=always --paging=never {}' \
  | xargs bat --style=numbers --color=always --paging=always"

alias opencode="opencode --port"

alias win-start='podman-compose --file ~/.config/winapps/compose.yaml start'
alias win-stop='podman-compose --file ~/.config/winapps/compose.yaml stop'
alias win-status='podman ps --filter name=WinApps'

# Start starship prompt
eval "$(starship init zsh)"

# Stub function to activate conda
conda() {
    # Remove stub so it doesn’t call itself again
    unset -f conda

    # Load conda hook
    eval "$(/home/miguel/anaconda3/bin/conda shell.zsh hook)"

    # Call the real conda function with the original arguments
    conda "$@"
}

# Create a Tmux Dev Layout with nvim, opencode, and a terminal
devup() {
  [[ -z $TMUX ]] && { echo "You must be inside tmux to use devup."; return 1; }
 
  local current_dir="${PWD}"
  local editor_pane oc_pane tries pane_content
 
  editor_pane="$TMUX_PANE"
 
  tmux rename-window -t "$editor_pane" "dev"
 
  # Split full width — bottom 15% is the plain terminal (C)
  tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"
 
  # Split the top pane — opencode on the right 30% (A | B)
  oc_pane=$(tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
 
  # Launch opencode first
  tmux send-keys -t "$oc_pane" "opencode --port" C-m
 
  # Wait until opencode's TUI is fully rendered before launching nvim,
  # to prevent its startup OSC sequences from corrupting nvim's terminal state
  tries=0
  while (( tries < 30 )); do
    sleep 0.5
    pane_content=$(tmux capture-pane -t "$oc_pane" -p)
    if echo "$pane_content" | grep -q "Ask anything"; then
      break
    fi
    (( tries++ ))
  done
 
  # Launch nvim in the left pane
  tmux send-keys -t "$editor_pane" "$EDITOR" C-m
 
  # Focus nvim
  tmux select-pane -t "$editor_pane"
}

# Setup direnv
eval "$(direnv hook zsh)"
