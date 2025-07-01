{ config, lib, pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        ControllerMode = "bredr";
      };
    };
  };
}
