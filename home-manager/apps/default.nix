{ config, lib, pkgs, ... }:

{
  imports = [
    ./brave.nix
    ./obsidian.nix
    ./mako.nix
    ./cliTools.nix
    ./ghostty.nix
  ];

  home.packages = with pkgs; [
    todoist-electron
    gimp-with-plugins
  ];
  nixpkgs.config.allowUnfree = true;
}
