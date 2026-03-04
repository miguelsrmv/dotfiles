#!/bin/bash

src="$THEME_DIR/$THEME/tmux.theme"
dest="$XDG_CONFIG_HOME/tmux/themes/theme.colors"

# Symlinks tmux theme and colors
if [ -f "$src" ]; then
	ln -sf "$src" "$dest"
fi

# Reload tmux only if a tmux server is running
if tmux info &>/dev/null; then
    tmux source-file "$XDG_CONFIG_HOME/tmux/tmux.conf"
fi
