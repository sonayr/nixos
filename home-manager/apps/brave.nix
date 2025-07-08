{ config, lib, pkgs, ... }:

{
  programs.brave = {
    enable = true;
    package = pkgs.brave;
    extensions = [
        { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } #vimium c
        { id = "hpijlohoihegkfehhibggnkbjhoemldh"; } #Salesforce Inspector reloaded
        { id = "hdokiejnpimakedhajhdlcegeplioahd"; } #Last Pass
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } #Dark Reader
    ];
  };
}
