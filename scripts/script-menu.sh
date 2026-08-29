#!/usr/bin/env bash
SCRIPTS_DIR="$HOME/nixos/scripts"

if [ ! -d "$SCRIPTS_DIR" ]; then
    notify-send "Script Library" "Scripts directory not found at $SCRIPTS_DIR"
    exit 1
fi

selected=$(find "$SCRIPTS_DIR" -maxdepth 1 -type f \( -executable -o -name "*.py" -o -name "*.sh" \) -printf "%f\n" | sort | wofi --dmenu --prompt "Script Library:")

if [ -n "$selected" ]; then
    script_path="$SCRIPTS_DIR/$selected"
    if [ -x "$script_path" ] || [[ "$selected" == *.sh ]]; then
        ghostty -e bash -c "$script_path"
    elif [[ "$selected" == *.py ]]; then
        ghostty -e python3 "$script_path"
    fi
fi
