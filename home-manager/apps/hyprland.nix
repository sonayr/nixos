{ config, lib, pkgs, osConfig ? null, ... }:

let
  isMac = osConfig != null && osConfig.networking.hostName == "mac";
in
{
  config = lib.mkIf isMac {
    wayland.windowManager.hyprland = {
      enable = true;
      
      settings = {
        monitor = ",preferred,auto,1";

        exec-once = [
          "waybar"
          "hyprpaper"
          "hypridle"
          "copyq --start-server"
        ];

        "$terminal" = "ghostty";
        "$menu" = "wofi --show drun";
        "$fileManager" = "thunar";

        env = [
          "XCURSOR_SIZE,24"
          "QT_QPA_PLATFORMTHEME,qt5ct"
        ];

        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          follow_mouse = 1;

          touchpad = {
            natural_scroll = true;
            tap-to-click = true;
            clickfinger_behavior = true;
          };

          sensitivity = 0;
        };

        gestures = {
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        misc = {
          disable_hyprland_logo = true;
        };

        "$mod" = "SUPER";

        bind = [
          "$mod, T, exec, $terminal"
          "$mod, Q, killactive,"
          "$mod, M, exit,"
          "$mod, E, exec, $fileManager"
          "$mod, V, togglefloating,"
          "$mod, Space, exec, $menu"
          "$mod, P, pseudo,"
          "$mod, J, togglesplit,"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"

          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"

          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86MonBrightnessUp, exec, brightnessctl s 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        ];

        bindl = [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
        ];
      };
    };
  };
}