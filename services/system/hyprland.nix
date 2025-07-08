{ pkgs, lib, ... }:
{

  environment = {
    systemPackages = with pkgs; [
      hyprland
      hyprlock
      hyprpicker
      inotify-tools
      waybar
      libglvnd
      hyprshot
      hyprpaper
      wofi
      copyq
      wl-clipboard
      blueman
      playerctl
      brightnessctl
    ];
  };

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
