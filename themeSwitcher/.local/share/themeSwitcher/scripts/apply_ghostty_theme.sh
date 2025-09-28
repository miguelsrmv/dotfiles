#!/bin/bash

config_file="$XDG_CONFIG_HOME/ghostty/config"

# Ensure the config file exists
[ -f "$config_file" ] || touch "$config_file"

# Ensure it includes the theme directive (append only if missing)
grep -qxF 'config-file = ?"~/.config/ghostty/ghostty.theme"' "$config_file" \
|| echo 'config-file = ?"~/.config/ghostty/ghostty.theme"' >> "$config_file"

# Symlink config to current theme
ln -sf "$THEME_DIR/$THEME/ghostty.theme" "$XDG_CONFIG_HOME/ghostty/ghostty.theme"

# Reload ghostty config
pkill -SIGUSR2 ghostty
