#!/bin/bash

# Get current Desktop environment
if pgrep -x Hyprland >/dev/null; then
	DESKTOP_ENVIRONMENT="Hyprland"
elif pgrep -x gnome-shell >/dev/null; then
	DESKTOP_ENVIRONMENT="GNOME"
fi	
