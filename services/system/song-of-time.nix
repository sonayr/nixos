{ config, lib, pkgs, ... }:

let
  cfg = config.services.song-of-time;

  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.numpy
    ps.scipy
  ]);

  songOfTimeListener = pkgs.writeShellScriptBin "song-of-time-listener" ''
    export PATH="${lib.makeBinPath [ pkgs.alsa-utils pkgs.pipewire pkgs.procps ]}:$PATH"
    exec ${pythonEnv}/bin/python ${./song-of-time/listener.py} "$@"
  '';

  songOfTimeStatus = pkgs.writeShellScriptBin "song-of-time-status" ''
    export PATH="${lib.makeBinPath [ pkgs.systemd pkgs.procps pkgs.coreutils ]}:$PATH"

    RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    STATUS_FILE="$RUNTIME_DIR/song-of-time.status"
    LOCK_PID_FILE="$RUNTIME_DIR/song-of-time.lockpid"
    DONE_FILE="$RUNTIME_DIR/song-of-time.done"

    HYPRLOCK_PID=$(pgrep -u "$(id -u)" -x hyprlock | head -n 1)

    if [ -n "$HYPRLOCK_PID" ]; then
      LAST_PID=""
      [ -f "$LOCK_PID_FILE" ] && LAST_PID=$(cat "$LOCK_PID_FILE" 2>/dev/null)
      if [ "$HYPRLOCK_PID" != "$LAST_PID" ]; then
        echo "$HYPRLOCK_PID" > "$LOCK_PID_FILE"
        rm -f "$DONE_FILE" "$STATUS_FILE"
      fi

      if [ ! -f "$DONE_FILE" ]; then
        if ! systemctl --user is-active --quiet song-of-time.service 2>/dev/null; then
          systemctl --user start song-of-time.service 2>/dev/null &
        fi
      fi
    fi

    if [ -f "$STATUS_FILE" ]; then
      cat "$STATUS_FILE"
    fi
  '';

in
{
  options.services.song-of-time = {
    enable = lib.mkEnableOption "Song of Time audio unlock for hyprlock";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      songOfTimeListener
      songOfTimeStatus
    ];

    systemd.user.services.song-of-time = {
      description = "Song of Time audio listener for hyprlock";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${songOfTimeListener}/bin/song-of-time-listener";
        Restart = "no";
        RuntimeMaxSec = "65";
      };
    };
  };
}
