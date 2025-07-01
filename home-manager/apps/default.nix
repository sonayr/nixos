{ config, lib, pkgs, ... }:

{
  imports = [
    ./brave.nix
    ./obsidian.nix
  ];

  home.packages = with pkgs; [
    todoist-electron
    gimp-with-plugins
  ];
}
