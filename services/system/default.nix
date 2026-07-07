{ config, pkgs, lib, ... }:
{
  imports = [
    ./frigate.nix
    ./home-assistant.nix
    ./mosquitto.nix
    ./kanata.nix
    ./swap.nix
    ./hyprland.nix
    ./neovim.nix
    ./bluetooth.nix
  ];
}

