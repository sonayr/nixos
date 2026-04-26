{ config, pkgs, ... }:

{
  home.username = "ryan";
  home.homeDirectory = "/home/ryan";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  xdg.configFile."opencode/agent" = {
    source = ../../opencode/agent;
    recursive = true;
  };
  
  xdg.configFile."opencode/skill" = {
    source = ../../opencode/skill;
    recursive = true;
  };


# Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
