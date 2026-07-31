{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      "$menu" = "wofi --show drun";

      monitor = [
        ",preferred,auto,1"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
      };

      bind = [
        "$mod, T, exec, $terminal"
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, V, togglefloating"
        "$mod, Space, exec, $menu"
      ];
      
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}