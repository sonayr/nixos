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
    prowlarr.enable = true;
    jellyseerr.enable = true;
    readarr.enable = true;
    readarr-audiobook.enable = true;
  };
}
