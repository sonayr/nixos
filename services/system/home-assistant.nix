{ config, pkgs, ... }:

{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "mqtt"
      "mobile_app"
    ];
    customComponents = [
      pkgs.home-assistant-custom-components.frigate
    ];
    config = {
      default_config = {};
    };
  };
  networking.firewall.allowedTCPPorts = [ 8123 ];
}
