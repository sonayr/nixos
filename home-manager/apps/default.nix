{ config, lib, pkgs, ... }:

{
  imports = [
    ./brave.nix
    ./obsidian.nix
    ./mako.nix
  ];

  home.packages = with pkgs; [
    todoist-electron
    gimp-with-plugins
  ];
}
