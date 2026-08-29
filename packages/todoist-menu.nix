{ pkgs, todPkg }:
pkgs.writeShellScriptBin "todoist-menu" ''
  if ${pkgs.procps}/bin/pgrep -f "tod|wofi.*dmenu" >/dev/null; then
    ${pkgs.procps}/bin/pkill -f "tod|wofi.*dmenu"
  else
    TODOIST_API_TOKEN="$(${pkgs.coreutils}/bin/cat /run/secrets/todoist_api_token 2>/dev/null)"
    if [ -z "$TODOIST_API_TOKEN" ]; then
      ${pkgs.libnotify}/bin/notify-send "Todoist Error" "TODOIST_API_TOKEN environment variable or sops secret is not set"
      exit 1
    fi
    ${todPkg}/bin/tod auth token "$TODOIST_API_TOKEN" >/dev/null 2>&1
    
    task=$(${pkgs.coreutils}/bin/echo "" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Todoist Task:" --cache-file /dev/null)
    if [ -n "$task" ]; then
      if ${todPkg}/bin/tod task quick-add -c "$task" >/dev/null 2>&1; then
        ${pkgs.libnotify}/bin/notify-send "Todoist" "Added: $task"
      else
        ${pkgs.libnotify}/bin/notify-send "Todoist Error" "Failed to add task"
      fi
    fi
  fi
''
