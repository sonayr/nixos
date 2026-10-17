{ pkgs, todPkg }:
let
  wofiStyle = pkgs.writeText "todoist-wofi-style.css" ''
    window {
      font-family: monospace;
      font-size: 14px;
      background-color: rgba(26, 27, 38, 0.95);
      border: 2px solid #7aa2f7;
      border-radius: 12px;
    }

    #outer-box {
      margin: 0px;
      padding: 0px;
      background-color: transparent;
    }

    #input {
      margin: 12px;
      padding: 10px 14px;
      border: none;
      border-radius: 8px;
      background-color: #24283b;
      color: #c0caf5;
    }

    #scroll, #inner-box, #entry {
      margin: 0px;
      padding: 0px;
      border: none;
      background-color: transparent;
    }

    #entry:selected {
      background-color: transparent;
    }
  '';
in
pkgs.writeShellScriptBin "todoist-menu" ''
  TODOIST_API_TOKEN="$(${pkgs.coreutils}/bin/cat /run/secrets/todoist_api_token 2>/dev/null)"
  if [ -z "$TODOIST_API_TOKEN" ]; then
    ${pkgs.libnotify}/bin/notify-send -u critical -a "Todoist" "Todoist Error" "TODOIST_API_TOKEN secret is not set"
    exit 1
  fi

  AUTH_MARKER="$HOME/.local/state/todoist_authed"
  TOKEN_HASH="$(${pkgs.coreutils}/bin/printf '%s' "$TODOIST_API_TOKEN" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.coreutils}/bin/cut -d' ' -f1)"
  LAST_HASH="$(${pkgs.coreutils}/bin/cat "$AUTH_MARKER" 2>/dev/null)"

  if [ "$TOKEN_HASH" != "$LAST_HASH" ]; then
    mkdir -p "$(${pkgs.coreutils}/bin/dirname "$AUTH_MARKER")"
    if ${todPkg}/bin/tod auth token "$TODOIST_API_TOKEN" >/dev/null 2>&1; then
      echo "$TOKEN_HASH" > "$AUTH_MARKER"
    else
      ${pkgs.libnotify}/bin/notify-send -u critical -a "Todoist" "Todoist Error" "Authentication failed"
      exit 1
    fi
  fi

  task=$(${pkgs.coreutils}/bin/printf "" | ${pkgs.wofi}/bin/wofi --dmenu --lines 0 --height 60 --style ${wofiStyle} --exec-search --prompt "Todoist Task (#project @label p1-p4):" --cache-file /dev/null)

  # Trim leading and trailing whitespace
  task="$(echo "$task" | ${pkgs.gnused}/bin/sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

  if [ -n "$task" ]; then
    (
      NID=$(${pkgs.libnotify}/bin/notify-send -p -a "Todoist" "Todoist" "Adding: $task...")
      if ${todPkg}/bin/tod task quick-add -c "$task" >/dev/null 2>&1; then
        ${pkgs.libnotify}/bin/notify-send -r "$NID" -a "Todoist" "Todoist" "✓ Added: $task"
      else
        ${pkgs.libnotify}/bin/notify-send -r "$NID" -u critical -a "Todoist" "Todoist Error" "Failed to add task: $task"
      fi
    ) &
  fi
''
