{ config, lib, pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        ControllerMode = "dual";
      };
    };
  };
  services.blueman.enable = true;
}
