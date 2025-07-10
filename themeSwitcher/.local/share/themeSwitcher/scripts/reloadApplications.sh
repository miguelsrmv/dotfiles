 # Reload Neovim (if running)
 # No need to do anything, watcher is already in service there

# Reload Tmux (if running)
if pgrep tmux > /dev/null; then
    tmux source-file ~/.tmux.conf
fi

# Reload Ghostty (if running; uses alt + r keybind set on Ghostty's config)
if pgrep ghostty > /dev/null; then
	ydotool key 56:1 19:1 19:0 56:0
fi

# Reload Btop (if running; uses hack to force btop reload)
if pgrep btop > /dev/null; then
    # Get all tmux panes with detailed info
    tmux_info=$(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} #{pane_pid} #{pane_current_command} #{pane_current_path}" 2>/dev/null)

    if [ -z "$tmux_info" ]; then
        return
    fi

    # Find panes currently running btop
    btop_panes=$(echo "$tmux_info" | grep " btop " | awk '{print $1}')

    if [ -z "$btop_panes" ]; then

        # Check if btop is running outside tmux
        if pgrep btop > /dev/null; then
            pkill btop
            sleep 0.5
            nohup btop > /dev/null 2>&1 &
        fi
        return
    fi

    # Restart btop in each pane where it's running
    for pane in $btop_panes; do
        # Send Ctrl+C to quit btop
        tmux send-keys -t "$pane" C-c
        sleep 0.5

        # Wait for btop to actually quit
        attempts=0
        while [ $attempts -lt 10 ]; do
            if ! tmux capture-pane -t "$pane" -p | grep -q "btop"; then
                break
            fi
            sleep 0.1
            attempts=$((attempts + 1))
        done

        # Clear and restart btop
        tmux send-keys -t "$pane" "clear && btop" Enter
    done
fi

