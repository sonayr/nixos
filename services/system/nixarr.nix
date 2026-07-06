{ config, pkgs, ... }:

{
  nixarr = {
    enable = true;
    mediaDir = "/mnt/storage-pool/media";
    stateDir = "/data/.state/nixarr";

    vpn = {
      enable = true;
      wgConf = config.sops.secrets.wg_conf.path;
    };

    jellyfin.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    transmission.enable = true;
    transmission.vpn.enable = true;
    prowlarr.enable = true;
    jellyseerr.enable = true;
    bazarr.enable = true;
    readarr.enable = false;
  };

  # Fix for Jellyfin "invalid language tag" error in admin dashboard
  systemd.services.jellyfin.environment = {
    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
    MALLOC_ARENA_MAX = "2";
  };

  # Fix for Jellyfin hardware acceleration permissions
  systemd.services.jellyfin.serviceConfig = {
    PrivateUsers = pkgs.lib.mkForce false;
    DeviceAllow = pkgs.lib.mkForce [
      "char-drm rw"
      "/dev/dri/renderD128 rw"
      "/dev/dri/card1 rw"
      "/dev/nvidia0 rw"
      "/dev/nvidiactl rw"
      "/dev/nvidia-modeset rw"
      "/dev/nvidia-uvm rw"
      "/dev/nvidia-uvm-tools rw"
    ];
    DevicePolicy = pkgs.lib.mkForce "auto";
    SystemCallFilter = pkgs.lib.mkForce [];
    RestrictAddressFamilies = pkgs.lib.mkForce [];
    UMask = pkgs.lib.mkForce "0022";
    RestrictNamespaces = pkgs.lib.mkForce false;
    RestrictRealtime = pkgs.lib.mkForce false;
    RestrictSUIDSGID = pkgs.lib.mkForce false;
    NoNewPrivileges = pkgs.lib.mkForce false;
    ProtectSystem = pkgs.lib.mkForce false;
    ProtectProc = pkgs.lib.mkForce "default";
    ProtectHostname = pkgs.lib.mkForce false;
    ProtectClock = pkgs.lib.mkForce false;
    ProtectKernelTunables = pkgs.lib.mkForce false;
    ProtectKernelModules = pkgs.lib.mkForce false;
    ProtectKernelLogs = pkgs.lib.mkForce false;
    ProtectControlGroups = pkgs.lib.mkForce false;
  };

  services.transmission.settings = {
    ratio-limit-enabled = true;
    ratio-limit = 1.0;
  };
  
  services.flaresolverr = {
    enable = true;
    port = 8191;
  };

  # 8083 for Calibre-Web, 8084 for Shelfmark, 8191 for FlareSolverr, 8096 for Jellyfin
  networking.firewall.allowedTCPPorts = [ 8083 8084 8191 8096 ];

  # 1900, 7359 for Jellyfin DLNA and discovery
  networking.firewall.allowedUDPPorts = [ 1900 7359 ];

  services.calibre-web = {
    enable = true;
    listen = {
      ip = "0.0.0.0"; # Or "127.0.0.1" if using a reverse proxy
      port = 8083;
    };
    options = {
      calibreLibrary = "/mnt/storage-pool/media/library/books";
      enableBookUploading = true;
      enableBookConversion = true;
    };
  };

  systemd.services.shelfmark = {
    description = "Shelfmark - Web interface for Calibre-Web";
    after = [ "network.target" "calibre-web.service" ];
    wantedBy = [ "multi-user.target" ];
    
    environment = {
      FLASK_HOST = "0.0.0.0";
      FLASK_PORT = "8084";
      CONFIG_DIR = "/var/lib/shelfmark";
      CWA_DB_PATH = "/var/lib/calibre-web/app.db";
      INGEST_DIR = "/mnt/storage-pool/media/library/books";
      TMP_DIR = "/var/lib/shelfmark/tmp";
    };

    serviceConfig = {
      Type = "simple";
      User = "calibre-web";
      Group = "calibre-web";
      ExecStart = "${pkgs.shelfmark}/bin/shelfmark --bind 0.0.0.0:8084";
      Restart = "on-failure";
      StateDirectory = "shelfmark";
      LogsDirectory = "shelfmark";
      WorkingDirectory = "/var/lib/shelfmark";
      
      # Security hardening (optional but recommended)
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [ "/var/lib/shelfmark" "/mnt/storage-pool/media/library/books" "/var/lib/calibre-web" ];
    };
  };
}
