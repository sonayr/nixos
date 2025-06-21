{ config, lib, pkgs, ... }:

{
  imports = [
    ./brave.nix
  ];

  home.packages = with pkgs; [
    todoist-electron
    obsidian
    gimp-with-plugins
  ];
}
