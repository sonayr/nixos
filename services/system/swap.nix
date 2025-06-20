{ config, pkgs, lib, ... }:

{

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4096;
      options = [ "discard" ];
    }
  ];
}
