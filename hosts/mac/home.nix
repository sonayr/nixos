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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    (pkgs.callPackage ../../packages/tod.nix { })
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
  };

  home.sessionVariables = {
    # EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.
}
