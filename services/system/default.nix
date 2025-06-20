{ config, pkgs, lib, ... }:
{
    imports = [
        ./kanata.nix
        ./swap.nix
        ./hyprland.nix
        ./neovim.nix
    ];
}

