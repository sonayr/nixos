{ config, pkgs, ... }:

let
  scriptMenu = pkgs.writeShellScriptBin "script-menu" ''
    exec $HOME/nixos/scripts/script-menu.sh
  '';
in
{
  home.packages = [
    scriptMenu
    pkgs.python3
  ];
}
