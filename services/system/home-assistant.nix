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
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
      automation = "!include automations.yaml";
    };
  };
  networking.firewall.allowedTCPPorts = [ 8123 ];
}
