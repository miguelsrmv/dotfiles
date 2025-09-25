GHOSTTY_THEME=Everforest
GHOSTTY_THEME_DIR=$DOTFILES_DIR/ghostty/.config/ghostty/themes

mkdir -p $GHOSTTY_THEME_DIR
ln -sf $THEME_DIR/$THEME/everforest_dark.theme $GHOSTTY_THEME_DIR/$GHOSTTY_THEME
