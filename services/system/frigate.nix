{ config, pkgs, ... }:

{
  systemd.services.frigate.serviceConfig.EnvironmentFile = [
    config.sops.templates."frigate_env".path
  ];

  services.frigate = {
    enable = true;
    hostname = "server";

    settings = {
      mqtt = {
        enabled = false;
      };

      go2rtc = {
        streams = {
          doorbell = [
            "rtsp://admin:{FRIGATE_CAMERA_PASSWORD}@192.168.5.68:554/h264Preview_01_main"
          ];
        };
      };

      cameras = {
        doorbell = {
          ffmpeg = {
            inputs = [
              {
                path = "rtsp://127.0.0.1:8554/doorbell";
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

  services.nginx.virtualHosts."server".listen = [
    { addr = "0.0.0.0"; port = 5000; }
  ];

  # Open port for Frigate UI and go2rtc
  networking.firewall.allowedTCPPorts = [ 5000 8554 8555 ];
  networking.firewall.allowedUDPPorts = [ 8555 ];
}
