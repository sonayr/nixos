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
      automation = [
        {
          alias = "Notify on Doorbell Person Detection";
          trigger = [
            {
              platform = "state";
              entity_id = "binary_sensor.doorbell_person_occupancy";
              from = "off";
              to = "on";
            }
          ];
          action = [
            {
              service = "notify.mobile_app_ryans_samsung";
              data = {
                title = "Motion Alert";
                message = "A person was detected at the doorbell!";
              };
            }
          ];
        }
      ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 8123 ];
}
