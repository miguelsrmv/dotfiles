STARSHIP_CONFIG=$DOTFILES_DIR/starship/.config/starship.toml

sed -i "s/^palette = \".*\"/palette = \"$THEME\"/" "$STARSHIP_CONFIG"
sed -i "s/^\[palettes\..*\]/[palettes.$THEME]/" "$STARSHIP_CONFIG"

sed -i "s/^error_status = \".*\"/error_status = \"$ERROR_STATUS\"/" "$STARSHIP_CONFIG"
sed -i "s/^success_status = \".*\"/success_status = \"$SUCCESS_STATUS\"/" "$STARSHIP_CONFIG"

sed -i "s/^replace_mode = \".*\"/replace_mode = \"$REPLACE_MODE\"/" "$STARSHIP_CONFIG"
sed -i "s/^visual_mode = \".*\"/visual_mode = \"$VISUAL_MODE\"/" "$STARSHIP_CONFIG"

sed -i "s/^bg = \".*\"/bg = \"$BG\"/" "$STARSHIP_CONFIG"
sed -i "s/^dir_fg = \".*\"/dir_fg = \"$DIR_FG\"/" "$STARSHIP_CONFIG"
sed -i "s/^git_fg = \".*\"/git_fg = \"$GIT_FG\"/" "$STARSHIP_CONFIG"
sed -i "s/^time_fg = \".*\"/time_fg = \"$TIME_FG\"/" "$STARSHIP_CONFIG"

