{ pkgs, todPkg }:
pkgs.writeShellScriptBin "todoist-menu" ''
  TODOIST_API_TOKEN="$(${pkgs.coreutils}/bin/cat /run/secrets/todoist_api_token 2>/dev/null)"
  if [ -z "$TODOIST_API_TOKEN" ]; then
    ${pkgs.libnotify}/bin/notify-send "Todoist Error" "TODOIST_API_TOKEN environment variable or sops secret is not set"
    exit 1
  fi

  AUTH_MARKER="$HOME/.local/state/todoist_authed"
  if [ ! -f "$AUTH_MARKER" ]; then
    mkdir -p "$(dirname "$AUTH_MARKER")"
    (${todPkg}/bin/tod auth token "$TODOIST_API_TOKEN" >/dev/null 2>&1 && touch "$AUTH_MARKER") &
  fi
  
  task=$(${pkgs.coreutils}/bin/echo "" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Todoist Task:" --cache-file /dev/null)
  if [ -n "$task" ]; then
    if ${todPkg}/bin/tod task quick-add -c "$task" >/dev/null 2>&1; then
      ${pkgs.libnotify}/bin/notify-send "Todoist" "Added: $task"
    else
      ${pkgs.libnotify}/bin/notify-send "Todoist Error" "Failed to add task"
    fi
  fi
''
