# ─── XDG Base Directory Specification ───────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ─── Zsh config ─────────────────────────────────────────────────────
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTSIZE=1000
export SAVEHIST=1000
export HISTFILE="$XDG_CONFIG_HOME/zsh/.zsh_history"

# ─── Dotfiles config ────────────────────────────────────────────────
export DOTFILESDIR="$HOME/.dotfiles"

# ─── Hostname ───────────────────────────────────────────────────────
export HOSTNAME=$(cat /etc/hostname)

# ─── Editor / Pager ─────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"
export MANPAGER="nvim +Man!"
export PAGER="less"

# ─── Obsidian Vault ─────────────────────────────────────────────────
export OBSIDIAN_VAULT="$HOME/Obsidian/MainVault"

# ─── PATH ───────────────────────────────────────────────────────────
export PATH="$PATH:$HOME/.local/bin:$XDG_DATA_HOME/npm/bin:$HOME/.cargo/bin"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# ─── KEYS ───────────────────────────────────────────────────────────
export GEMINI_API_KEY="AIzaSyCKV7u34fraE8WDN4tO2Exyr_85fLCtg20"
