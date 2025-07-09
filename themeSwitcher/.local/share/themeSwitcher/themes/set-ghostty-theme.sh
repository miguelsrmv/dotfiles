GHOSTTY_CONFIG=$DOTFILES_DIR/ghostty/.config/ghostty/config
sed -i 's/^theme = ".*"$/theme = "'"$GHOSTTY_THEME"'"/' $GHOSTTY_CONFIG
