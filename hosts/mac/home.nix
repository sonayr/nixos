{ config, pkgs, ... }:

{
  imports = [
    ../../home-manager/apps/ghostty.nix
    ../../home-manager/apps/zsh.nix
    ./hyprland.nix
    ../../home-manager/apps/default.nix
    ../../home-manager/modules/nixvim.nix

  ];

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.packages = let
    todPkg = pkgs.callPackage ../../packages/tod.nix { };
    todoistMenu = pkgs.callPackage ../../packages/todoist-menu.nix { inherit todPkg; };
  in [
    todPkg
    pkgs.python3Packages.toggl-cli
    pkgs.opencode
    todoistMenu
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    image = ../../home-manager/assets/wallpapers/sheik-oot.jpg;
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.
}
