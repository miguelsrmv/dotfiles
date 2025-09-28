#!/bin/bash

btop_conf="$HOME/.config/btop/btop.conf"
btop_theme_file="$THEME_DIR/$THEME/btop.theme"
btop_theme_dest="$DOTFILES_DIR/btop/.config/btop/themes"

# Ensure btop config exists
[ -f "$btop_conf" ] || return

# Symlinks btop theme
if [ -f "$btop_theme_file" ]; then
	mkdir -p "$(dirname "$btop_theme_dest")"
	ln -sf "$btop_theme_file" "$btop_theme_dest/current.theme"
fi

# Reload btop config
pkill -SIGUSR2 btop 2>/dev/null || true

