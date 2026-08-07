{ config, pkgs, ... }:

{
  imports = [
    ../../home-manager/apps/opencode.nix
  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";
  home.stateVersion = "24.11"; # Please read the comment before changing.


# Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
