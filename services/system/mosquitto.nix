{ config, pkgs, ... }:

{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
        port = 1883;
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [ 1883 ];
}
