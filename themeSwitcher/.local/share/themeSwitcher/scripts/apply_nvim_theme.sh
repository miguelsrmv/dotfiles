#!/bin/bash
THEME=$(cat "$HOME/.local/share/themeSwitcher/current_theme.txt")

case "$THEME" in
  catppuccin)
    NVIM_THEME="catppuccin-macchiato"
    ;;
  catppuccin-latte)
    NVIM_THEME="catppuccin-latte"
    ;;
  dracula)
    NVIM_THEME="dracula"
    ;;
  everforest)
    NVIM_THEME="everforest"
    ;;
  gruvbox)
    NVIM_THEME="gruvbox"
    ;;
  kanagawa)
    NVIM_THEME="kanagawa"
    ;;
  nightfox)
    NVIM_THEME="nightfox"
    ;;
  nord)
    NVIM_THEME="nord"
    ;;
  one-dark-pro)
    NVIM_THEME="onedark"
    ;;
  ristretto)
    NVIM_THEME="monokai-pro-ristretto"
    ;;
  rose-pine)
    NVIM_THEME="rose-pine"
    ;;
  tokyo-night)
    NVIM_THEME="tokyonight-night"
    ;;
  *)
    NVIM_THEME="default"
    ;;
esac

# Find all running nvim sockets and send the theme change to each
for sock in /tmp/nvim-*.sock; do
  [ -S "$sock" ] || continue  # skip if not a valid socket
  nvim --server "$sock" --remote-expr "execute('colorscheme $NVIM_THEME')" 2>/dev/null || true
done
