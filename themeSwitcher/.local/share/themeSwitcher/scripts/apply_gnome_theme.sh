#!/bin/bash

# Source theme-specific GNOME setup if present
[ -f "$THEME_DIR/$THEME/gnome.sh" ] && source "$THEME_DIR/$THEME/gnome.sh"

# Apply shell / GTK / icon settings
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita (default)'
gsettings set org.gnome.desktop.interface gtk-theme "Yaru-$THEME_COLOR-dark"
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.interface accent-color "$THEME_COLOR" 2>/dev/null || true

# Prepare background paths
BACKGROUND_ORG_PATH="$HOME/.local/share/themeSwitcher/themes/$THEME_BACKGROUND"
BACKGROUND_DEST_DIR="$HOME/.local/share/backgrounds"
BACKGROUND_DEST_PATH="$BACKGROUND_DEST_DIR/$(echo "$THEME_BACKGROUND" | tr '/' '-')"

# Apply background in GNOME
gsettings set org.gnome.desktop.background picture-uri "file://$THEME_DIR/$THEME/background.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$THEME_DIR/$THEME/background.png"
gsettings set org.gnome.desktop.background picture-options 'zoom'
