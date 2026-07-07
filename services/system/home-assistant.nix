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
      http = {
        server_host = [ "0.0.0.0" ];
        server_port = 8123;
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 8123 ];
}
