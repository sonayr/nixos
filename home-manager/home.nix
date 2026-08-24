{ config, pkgs, self, osConfig ? null, ... }:
{
  imports = [
    ./apps
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.

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

  # programs.chromium = {
  #   enable = true;
  #   package = pkgs.brave;
  #   extensions = [
  #       { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } #vimium c
  #       { id = "hpijlohoihegkfehhibggnkbjhoemldh"; } #Salesforce Inspector reloaded
  #       { id = "hdokiejnpimakedhajhdlcegeplioahd"; } #Last Pass
  #   ];
  # };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home-manager/dotfiles/nvim/.config/nvim";
    ".config/hypr/hyprland.conf" = pkgs.lib.mkIf (osConfig.networking.hostName != "mac") {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home-manager/dotfiles/hypr/.config/hypr/laptop-hyprland.conf";
      force = true;
    };
    ".config/hypr/hyprpaper.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home-manager/dotfiles/hypr/.config/hypr/hyprpaper.conf";
    };
    ".config/hypr/ocarina.jpg" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home-manager/dotfiles/hypr/.config/hypr/ocarina.jpg";
    };
    ".config/hypr/scripts" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home-manager/dotfiles/hypr/.config/hypr/scripts";
    };
    ".config/waybar" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home-manager/dotfiles/waybar/.config/waybar";
    };
    ".config/zsh" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home-manager/dotfiles/zsh";
    };
    ".zshenv".text = "ZDOTDIR=~/.config/zsh";
    ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home-manager/dotfiles/tmux/.tmux.conf";
    ".local/bin".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home-manager/dotfiles/scripts/.local/bin";

    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

  };
  home.sessionVariables = {
    vim = "nvim";
    XCURSOR_SIZE = "32";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
