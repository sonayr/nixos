{ config, pkgs, ... }:

{
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 28981;
    passwordFile = "/tmp/paperless-password.txt";
    consumptionDirIsPublic = true;
    settings = {
      PAPERLESS_OCR_LANGUAGE = "eng";
    };
  };

  # Make sure the user has access to drop files into the consumption directory
  systemd.tmpfiles.rules = [
    "d /var/lib/paperless/consume 0775 paperless users -"
  ];

  # Allow traffic to paperless
  networking.firewall.allowedTCPPorts = [ 28981 ];
}
