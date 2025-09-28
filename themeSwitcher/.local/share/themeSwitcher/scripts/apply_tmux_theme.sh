#!/bin/bash

src="$THEME_DIR/$THEME/tmux.theme"
dest="$XDG_CONFIG_HOME/tmux/themes/theme.colors"

# Symlinks tmux theme and colors
if [ -f "$src" ]; then
	ln -sf "$src" "$dest"
fi

# Reloads tmux
tmux source-file $XDG_CONFIG_HOME/tmux/tmux.conf
