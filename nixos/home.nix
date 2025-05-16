{ config, pkgs, self, ... }:
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ry";
  home.homeDirectory = "/home/ry";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
        pkgs.luajitPackages.luarocks-nix
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
     ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/mysystem/home-manager/dotfiles/nvim/.config/nvim";
     ".config/hypr/" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/mysystem/home-manager/dotfiles/hypr/.config/hypr";
        force = true;
    };
    ".config/waybar" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/mysystem/home-manager/dotfiles/waybar/.config/waybar";
    };
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

  };
  home.sessionVariables = {
     vim = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
