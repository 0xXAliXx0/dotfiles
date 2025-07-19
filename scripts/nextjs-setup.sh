#!/bin/bash
# Move the current terminal to workspace 3
hyprctl dispatch movetoworkspace 3

# Switch to workspace 1 for neovim and Firefox
hyprctl dispatch workspace 1

# Change this to your project path
PROJECT_PATH="/home/ali/nextjs/e-commer"
LOG_FILE="$HOME/scripts/nextjs-setup.log"
cd "$PROJECT_PATH"

# Open neovim in terminal (workspace 1)
kitty -e nvim . 2>>"$LOG_FILE" &

# Wait a moment for neovim to open
sleep 1

# Start Next.js dev server in workspace 2
hyprctl dispatch workspace 2
sleep 0.5
kitty --title "NextJS Dev Server" sh -c "npm run dev; read" 2>>"$LOG_FILE" &
sleep 1

# Switch back to workspace 1
hyprctl dispatch workspace 1

# Wait 3 seconds then open Firefox in workspace 1
sleep 3
firefox --new-window http://localhost:3000 2>>"$LOG_FILE" &

# Wait for Firefox to open
sleep 2

# Make sure we're in workspace 1
hyprctl dispatch workspace 1

# Log the script execution
echo "$(date): NextJS setup script executed" >> "$LOG_FILE"
