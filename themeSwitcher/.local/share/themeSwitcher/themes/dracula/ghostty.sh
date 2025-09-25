GHOSTTY_THEME=Dracula
GHOSTTY_THEME_DIR=$DOTFILES_DIR/ghostty/.config/ghostty/themes

mkdir -p $GHOSTTY_THEME_DIR
ln -sf $THEME_DIR/$THEME/dracula_mofiqul.theme $GHOSTTY_THEME_DIR/$GHOSTTY_THEME
