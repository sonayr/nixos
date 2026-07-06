{ config, pkgs, ... }:

{
  systemd.services.frigate.serviceConfig.EnvironmentFile = [
    config.sops.templates."frigate_env".path
  ];

  # Make go2rtc aware of the password
  systemd.services.go2rtc.serviceConfig.EnvironmentFile = [
    config.sops.templates."frigate_env".path
  ];

  services.go2rtc = {
    enable = true;
    settings = {
      rtsp = {
        listen = ":8554";
      };
      webrtc = {
        listen = ":8555";
      };
      streams = {
        doorbell = [
          "rtsp://admin:\${FRIGATE_CAMERA_PASSWORD}@192.168.5.68:554/h264Preview_01_main"
        ];
        doorbell_sub = [
          "rtsp://admin:\${FRIGATE_CAMERA_PASSWORD}@192.168.5.68:554/h264Preview_01_sub"
        ];
      };
    };
  };

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
                path = "rtsp://127.0.0.1:8554/doorbell";
                roles = [ "record" ];
              }
              {
                path = "rtsp://127.0.0.1:8554/doorbell_sub";
                roles = [ "detect" ];
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
