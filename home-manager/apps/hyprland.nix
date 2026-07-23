{ config, lib, pkgs, osConfig ? null, ... }:

let
  isMac = osConfig != null && osConfig.networking.hostName == "mac";
in
{
  config = lib.mkIf isMac {
    # Instead of using the Home Manager Wayland Window Manager module which can 
    # conflict with system-level setups, we will write the config manually
    # to maintain strict compatibility with Asahi Linux SDDM expectations.
    xdg.configFile."hypr/hyprland.conf".text = ''
      # -----------------------------------------------------
      # Generated Hyprland Base Configuration for Mac Host
      # -----------------------------------------------------
      monitor=,preferred,auto,1

      exec-once = waybar
      exec-once = hyprpaper
      exec-once = hypridle
      exec-once = copyq --start-server

      $terminal = ghostty
      $menu = wofi --show drun
      $fileManager = thunar

      env = XCURSOR_SIZE,24
      env = QT_QPA_PLATFORMTHEME,qt5ct

      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =

          follow_mouse = 1

          touchpad {
              natural_scroll = true
              tap-to-click = true
              clickfinger_behavior = true
          }

          sensitivity = 0
      }

      gestures {
          workspace_swipe = true
          workspace_swipe_fingers = 3
      }

      general {
          gaps_in = 5
          gaps_out = 10
          border_size = 2
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)
          layout = dwindle
      }

      decoration {
          rounding = 10
          blur {
              enabled = true
              size = 3
              passes = 1
          }
          shadow {
              enabled = true
              range = 4
              render_power = 3
              color = rgba(1a1a1aee)
          }
      }

      dwindle {
          pseudotile = true
          preserve_split = true
      }

      misc {
          disable_hyprland_logo = true
      }

      $mod = SUPER

      bind = $mod, T, exec, $terminal
      bind = $mod, Q, killactive,
      bind = $mod, M, exit,
      bind = $mod, E, exec, $fileManager
      bind = $mod, V, togglefloating,
      bind = $mod, Space, exec, $menu
      bind = $mod, P, pseudo,
      bind = $mod, J, togglesplit,

      bind = $mod, left, movefocus, l
      bind = $mod, right, movefocus, r
      bind = $mod, up, movefocus, u
      bind = $mod, down, movefocus, d

      bind = $mod, 1, workspace, 1
      bind = $mod, 2, workspace, 2
      bind = $mod, 3, workspace, 3
      bind = $mod, 4, workspace, 4
      bind = $mod, 5, workspace, 5

      bind = $mod SHIFT, 1, movetoworkspace, 1
      bind = $mod SHIFT, 2, movetoworkspace, 2
      bind = $mod SHIFT, 3, movetoworkspace, 3
      bind = $mod SHIFT, 4, movetoworkspace, 4
      bind = $mod SHIFT, 5, movetoworkspace, 5

      bind = $mod, mouse_down, workspace, e+1
      bind = $mod, mouse_up, workspace, e-1

      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow

      bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindel = , XF86MonBrightnessUp, exec, brightnessctl s 5%+
      bindel = , XF86MonBrightnessDown, exec, brightnessctl s 5%-

      bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioNext, exec, playerctl next
      bindl = , XF86AudioPrev, exec, playerctl previous
    '';
  };
}
