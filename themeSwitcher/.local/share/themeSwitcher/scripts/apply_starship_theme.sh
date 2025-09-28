#!/bin/bash

src="$THEME_DIR/$THEME/starship.toml"
dest="$XDG_CONFIG_HOME/starship.toml"

# Symlinks starship.toml
if [ -f "$src" ]; then
	ln -sf "$src" "$dest"
fi
