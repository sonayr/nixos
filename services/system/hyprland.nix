{ pkgs, lib, ... }:
{

  environment = {
    systemPackages = with pkgs; [
      hyprlock
      hyprpicker
      inotify-tools
      waybar
      hyprshot
      hyprpaper
      wofi
      copyq
      wl-clipboard
      blueman
      playerctl
      brightnessctl
    ];
    sessionVariables = {
      # Workaround for Hyprland 0.54.0+ crash on Asahi Linux (drmModifierName null pointer)
      AQ_NO_MODIFIERS = "1";
    };
  };

  hardware.graphics.enable = true;

  programs = {

    hyprland = {
      enable = true;
      withUWSM = true; # recommended for most users
      xwayland.enable = true; # Xwayland can be disabled.
    };

    hyprlock = {
      enable = true;
    };
  };

  services = {
    hypridle = {
      enable = true;
    };
  };
}
