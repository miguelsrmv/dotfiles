# Eliminates PATH duplicate entries
typeset -U path

# Ensures .local/bin is part of PATH
. "$HOME/.local//bin/env"

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

# Hook direnv
eval "$(direnv hook zsh)"
 
# Start starship prompt
eval "$(starship init zsh)"
