{ config, lib, pkgs, osConfig ? null, ... }:

let
  isMac = osConfig != null && osConfig.networking.hostName == "mac";
in
{
  config = lib.mkIf isMac {
    xdg.configFile."hypr/hyprland.conf".text = ''
# -----------------------------------------------------
# Hyprland Base Configuration for Mac Host (Asahi Linux)
# -----------------------------------------------------

# -- Monitors --
# If you have a Retina display, you may want to change the scaling to '2'
# e.g., monitor=,preferred,auto,2
monitor=,preferred,auto,1

# -- Autostart --
# These utilize the packages already in your services/system/hyprland.nix
exec-once = waybar
exec-once = hyprpaper
exec-once = hypridle
exec-once = copyq --start-server

# -- Programs --
$terminal = ghostty
$menu = wofi --show drun
$fileManager = thunar

# -- Environment Variables --
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct

# -- Input & Keyboard --
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1

    touchpad {
        natural_scroll = true      # Standard Mac behavior
        tap-to-click = true
        clickfinger_behavior = true
    }

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
}

# Gestures (Optimized for Mac trackpads)
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
}

# -- General --
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# -- Decoration --
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# -- Dwindle Layout --
dwindle {
    pseudotile = yes
    preserve_split = yes
}

# -- Misc --
misc {
    disable_hyprland_logo = true
}

# -- Bindings --
# Mac Command key is mapped to SUPER by default in most Asahi setups
$mod = SUPER

# Basic Binds
bind = $mod, T, exec, $terminal
bind = $mod, Q, killactive, 
bind = $mod, M, exit, 
bind = $mod, E, exec, $fileManager
bind = $mod, V, togglefloating, 
bind = $mod, Space, exec, $menu
bind = $mod, P, pseudo, # dwindle
bind = $mod, J, togglesplit, # dwindle

# Move focus
bind = $mod, left, movefocus, l
bind = $mod, right, movefocus, r
bind = $mod, up, movefocus, u
bind = $mod, down, movefocus, d

# Workspaces
bind = $mod, 1, workspace, 1
bind = $mod, 2, workspace, 2
bind = $mod, 3, workspace, 3
bind = $mod, 4, workspace, 4
bind = $mod, 5, workspace, 5

# Move active window to a workspace
bind = $mod SHIFT, 1, movetoworkspace, 1
bind = $mod SHIFT, 2, movetoworkspace, 2
bind = $mod SHIFT, 3, movetoworkspace, 3
bind = $mod SHIFT, 4, movetoworkspace, 4
bind = $mod SHIFT, 5, movetoworkspace, 5

# Scroll through existing workspaces
bind = $mod, mouse_down, workspace, e+1
bind = $mod, mouse_up, workspace, e-1

# Move/resize windows with mouse
bindm = $mod, mouse:272, movewindow
bindm = $mod, mouse:273, resizewindow

# Mac Media Keys & Hardware Controls
# Volume (Pipewire)
bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Screen Brightness (brightnessctl)
bindel = , XF86MonBrightnessUp, exec, brightnessctl s 5%+
bindel = , XF86MonBrightnessDown, exec, brightnessctl s 5%-

# Media Control (playerctl)
bindl = , XF86AudioPlay, exec, playerctl play-pause
bindl = , XF86AudioNext, exec, playerctl next
bindl = , XF86AudioPrev, exec, playerctl previous
    '';
  };
}
