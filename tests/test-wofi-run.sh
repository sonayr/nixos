#!/usr/bin/env bash
set -e

echo "Running wofi-run integration test..."

# Test 1: First invocation should write state and launch command
# Let's create a test wrapper for wofi-run that accepts STATE_FILE override if needed,
# or test using /tmp/wofi-current-menu.

rm -f /tmp/wofi-current-menu /tmp/wofi-active-pid

# Test invoking wofi-run with a mock command (e.g. sleep 1)
wofi-run testmenu sleep 1 &
PID1=$!

sleep 0.2
if [ "$(cat /tmp/wofi-current-menu 2>/dev/null)" = "testmenu" ]; then
    echo "PASS: State correctly set to testmenu"
else
    echo "FAIL: State not set correctly"
    exit 1
fi

# Test 2: Second invocation with same menu should toggle off (kill running command & remove state)
wofi-run testmenu sleep 1
sleep 0.2

if [ ! -f /tmp/wofi-current-menu ]; then
    echo "PASS: State file removed on toggle off"
else
    echo "FAIL: State file still exists after toggle off"
    exit 1
fi

echo "All tests passed successfully!"
