{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "mod" = { _var = "SUPER"; };
      "terminal" = { _var = "ghostty"; };
      "menu" = { _var = "wofi --show drun"; };

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
        (pkgs.lib.generators.mkLuaInline ''mod .. ", T, exec, " .. terminal'')
        (pkgs.lib.generators.mkLuaInline ''mod .. ", Q, killactive,"'')
        (pkgs.lib.generators.mkLuaInline ''mod .. ", M, exit,"'')
        (pkgs.lib.generators.mkLuaInline ''mod .. ", V, togglefloating,"'')
        (pkgs.lib.generators.mkLuaInline ''mod .. ", Space, exec, " .. menu'')
      ];
      
      bindm = [
        (pkgs.lib.generators.mkLuaInline ''mod .. ", mouse:272, movewindow"'')
        (pkgs.lib.generators.mkLuaInline ''mod .. ", mouse:273, resizewindow"'')
      ];
    };
  };
}
