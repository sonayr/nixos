{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    todoist
    gemini-cli
  ];
}
