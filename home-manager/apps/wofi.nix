{ config, pkgs, ... }:

let
  wofiRun = pkgs.writeShellScriptBin "wofi-run" ''
    STATE_FILE="/tmp/wofi-current-menu"
    MENU_ID="$1"
    shift

    CURRENT_ID="$(${pkgs.coreutils}/bin/cat "$STATE_FILE" 2>/dev/null)"

    # Force kill any existing wofi process immediately
    ${pkgs.procps}/bin/pkill -9 -x wofi 2>/dev/null

    if [ "$CURRENT_ID" = "$MENU_ID" ] && [ -n "$CURRENT_ID" ]; then
      rm -f "$STATE_FILE"
      exit 0
    fi

    echo "$MENU_ID" > "$STATE_FILE"
    "$@"
    rm -f "$STATE_FILE"
  '';
in
{
  home.packages = [ wofiRun ];

  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 350;
      location = "center";
      allow_images = true;
      image_size = 24;
      insensitive = true;
      normal_window = true;
      layer = "top";
      prompt = "Search...";
    };
    style = ''
      window {
          font-family: monospace;
          font-size: 14px;
          background-color: rgba(26, 27, 38, 0.9);
          border: 2px solid #7aa2f7;
          border-radius: 12px;
      }

      #input {
          margin: 15px;
          padding: 10px;
          border: none;
          border-radius: 8px;
          background-color: #24283b;
          color: #c0caf5;
      }

      #inner-box {
          margin: 0px 15px 15px 15px;
          background-color: transparent;
      }

      #outer-box {
          margin: 0px;
          background-color: transparent;
      }

      #scroll {
          margin: 0px;
          background-color: transparent;
      }

      #text {
          margin: 5px;
          color: #c0caf5;
      }

      #entry {
          padding: 8px 12px;
          border-radius: 6px;
          background-color: transparent;
      }

      #entry:selected {
          background-color: #3d59a1;
          color: #ffffff;
      }
    '';
  };
}
