{ config, pkgs, ... }:

{
  nixarr = {
    enable = true;
    mediaDir = "/data/media";
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
    transmission.extraSettings = {
      rpc-host-whitelist-enabled = false;
    };
    prowlarr.enable = true;
    jellyseerr.enable = true;
    readarr.enable = false;
  };
  
  networking.firewall.allowedTCPPorts = [ 8083 8084 9091 ]; # 8083 for Calibre-Web, 8084 for Shelfmark

  services.calibre-web = {
    enable = true;
    listen = {
      ip = "0.0.0.0"; # Or "127.0.0.1" if using a reverse proxy
      port = 8083;
    };
    options = {
      calibreLibrary = "/data/media/library/books";
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
      INGEST_DIR = "/data/media/library/books";
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
      ReadWritePaths = [ "/var/lib/shelfmark" "/data/media/library/books" "/var/lib/calibre-web" ];
    };
  };
}
