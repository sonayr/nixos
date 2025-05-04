# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: 
{
  home = {
    username = "ry";
    homeDirectory = "/home/ry";
    file = {
      ".config/neovim".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/nvim
    }
    packages = [
	pkgs.cowsay
    ]
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
