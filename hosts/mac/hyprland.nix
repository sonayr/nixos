{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      "$browser" = "brave";
      "$menu" = "wofi-run todoist todoist-menu";
      "$applauncher" = "wofi-run applauncher wofi --show drun";
      "$scriptmenu" = "wofi-run scripts script-menu";

      monitor = [
        ",preferred,auto,1.25"
      ];

      env = [
        "XCURSOR_SIZE,32"
      ];

      exec-once = [
        "uwsm app -- hyprpaper"
        "uwsm app -- mako"
        "uwsm app -- ags"
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
        "$mod, T,     exec, $terminal"
        "$mod, B,     exec, $browser"
        "$mod, Q,     killactive"
        "$mod, M,     exit"
        "$mod, V,     togglefloating"
        "$mod, Space, exec, $applauncher"
        "$mod SHIFT, Space, exec, $menu"
        "$mod CONTROL, Space, exec, $scriptmenu"
        
        ## MOVEMENT
        "$mod, F,     fullscreen"
        "$mod, J,     moveFocus, down"
        "$mod, K,     moveFocus, up"
        "$mod, H,     moveFocus, left"
        "$mod, L,     moveFocus, right"
        "$mod, Tab,   cyclenext"
        "$mod SHIFT, Tab, cyclenext, prev"
        "$mod, 1,     workspace, 1"
        "$mod, 2,     workspace, 2"
        "$mod, 3,     workspace, 3"
        "$mod, 4,     workspace, 4"
        "$mod, 5,     workspace, 5"
        "$mod, 6,     workspace, 6"
        "$mod, 7,     workspace, 7"
        "$mod, 8,     workspace, 8"
        "$mod, 9,     workspace, 9"
        "$mod, 0,     workspace, 10"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
         
        ## AUDIO
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
      
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      listener = [
        {
          timeout = 300;
          on-timeout = "${pkgs.hyprlock}/bin/hyprlock";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
