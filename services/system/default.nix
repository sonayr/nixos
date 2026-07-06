{ config, pkgs, lib, ... }:
{
  imports = [
    ./frigate.nix
    ./kanata.nix
    ./swap.nix
    ./hyprland.nix
    ./neovim.nix
    ./bluetooth.nix
  ];
}

