#!/usr/bin/env bash

# Start Toggl timer under project "Typing"
if command -v toggl &>/dev/null; then
    toggl start "MonkeyType Practice" --project "Typing" || toggl start --project "Typing"
fi

# Open browser with new window
setsid brave --new-window "https://monkeytype.com" "https://track.toggl.com" &

# Monitor window in background and stop toggl when Monkeytype window closes
if command -v hyprctl &>/dev/null; then
    (
        # Wait until the Monkeytype window actually opens
        while ! hyprctl clients | grep -qi "monkeytype"; do
            sleep 1
        done
        # Once open, wait until it closes
        while hyprctl clients | grep -qi "monkeytype"; do
            sleep 3
        done
        # Stop toggl timer
        if command -v toggl &>/dev/null; then
            toggl stop
        fi
    ) &
fi
