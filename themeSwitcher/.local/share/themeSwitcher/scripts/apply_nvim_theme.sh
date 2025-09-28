#!/bin/bash

src="$THEME_DIR/$THEME/neovim.lua"
dest="$XDG_CONFIG_HOME/nvim/lua/custom/theme_state.lua"

# Symlinks tmux theme and colors
if [ -f "$src" ]; then
	ln -sf "$src" "$dest"
fi
