#!/bin/bash

# Collect all subdirectories in THEME_DIR as valid themes, converts from kebab case to prper display
mapfile -t THEME_NAMES < <(find "$THEME_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g' | sort)

# Bail out early if no themes are found
if [ "${#THEME_NAMES[@]}" -eq 0 ]; then
	echo "No themes found in $THEME_DIR"
	exit 1
fi
