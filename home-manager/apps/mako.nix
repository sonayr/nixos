{ lib, pkgs, ... }:
{
  services.mako = {
    enable = true;
    settings = {
      "actionable=true" = {
        anchor = "top-right";
      };
      actions = true;
      anchor = "top-right";
      background-color = "#A282C34";
      border-color = "#010101";
      border-radius = 0;
      default-timeout = 2000;
      font = "monospace 10";
      text-color="#3892FE";
      height = 100;
      icons = true;
      ignore-timeout = false;
      layer = "top";
      margin = 10;
      markup = true;
      width = 300;
    };
  };
}
