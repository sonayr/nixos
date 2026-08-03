{ config, pkgs, ags, ... }:

{
  imports = [ ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = ../ags; # Sourcing from the new path outside of dotfiles
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk_4_1
      accountsservice
      upower
      networkmanager
    ];
  };
}
