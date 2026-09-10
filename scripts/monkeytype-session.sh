#!/usr/bin/env bash

# Open browser with Monkeytype and Toggl tabs
setsid brave --new-window "https://monkeytype.com" "https://track.toggl.com" &

# Start Toggl timer under project "MonkeyType"
if command -v toggl &>/dev/null; then
    toggl start "MonkeyType Practice" --project "Typing" || toggl start --project "Typing"
else
    echo "Toggl CLI not found."
fi
