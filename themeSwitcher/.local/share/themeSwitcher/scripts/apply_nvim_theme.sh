#!/bin/bash

NVIM_SOCK="/tmp/nvim.sock"
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

nvim --server "$NVIM_SOCK" --remote-send ":colorscheme $NVIM_THEME<CR>"
