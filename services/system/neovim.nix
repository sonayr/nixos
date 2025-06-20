{ pkgs, lib, ... }:

{
    environment.systemPackages = with pkgs; [
        neovim
        lf
        tmux
        ghostty
        ripgrep
        gcc
        fzf
    ];
}
