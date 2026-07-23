{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    
    settings = {
      font-family = "FiraCode Nerd Font";
      font-size = 14;
      theme = "catppuccin-mocha";
      window-padding-x = 10;
      window-padding-y = 10;
      background-opacity = 0.9;
    };
  };
}