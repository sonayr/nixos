{ config, pkgs, ... }:

let
  wofiToggle = pkgs.writeShellScriptBin "wofi-toggle" ''
    if ${pkgs.procps}/bin/pgrep -f "wofi --show drun" >/dev/null; then
      ${pkgs.procps}/bin/pkill -f "wofi --show drun"
    else
      ${pkgs.wofi}/bin/wofi --show drun
    fi
  '';
in
{
  home.packages = [ wofiToggle ];

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
