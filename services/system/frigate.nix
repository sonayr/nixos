{ config, pkgs, ... }:

{
  services.frigate = {
    enable = true;
    hostname = "server";

    settings = {
      mqtt = {
        enabled = false;
      };

      cameras = {
        doorbell = {
          ffmpeg = {
            inputs = [
              {
                path = "rtsp://admin:${config.sops.placeholder.frigate_camera_password}@192.168.5.68:554/h264Preview_01_main";
                roles = [ "record" "detect" ];
              }
            ];
          };
          detect = {
            enabled = true;
          };
          record = {
            enabled = true;
            retain = {
              days = 7;
              mode = "all";
            };
            events = {
              retain = {
                default = 14;
                mode = "motion";
              };
            };
          };
        };
      };
    };
  };

  # Open port for Frigate UI
  networking.firewall.allowedTCPPorts = [ 5000 ];
}
