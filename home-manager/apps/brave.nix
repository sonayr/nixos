
{ config, lib, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
        { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } #vimium c
        { id = "hpijlohoihegkfehhibggnkbjhoemldh"; } #Salesforce Inspector reloaded
        { id = "hdokiejnpimakedhajhdlcegeplioahd"; } #Last Pass
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } #Dark Reader

    ];
  };

  home.packages = [
     pkgs.brave
  ];
}
