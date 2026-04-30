# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../services/system/nixarr.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "server"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  # Enable networking
  networking.networkmanager.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ryan = {
    isNormalUser = true;
    description = "Ryan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    neovim
    opencode
    mergerfs
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable Samba for network shares
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "nixos-server";
        "netbios name" = "nixos-server";
        "security" = "user";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "storage" = {
        "path" = "/mnt/storage-pool";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "ryan";
        "force group" = "users";
      };
    };
  };

  # Enable WS-Discovery so Windows can easily find the Samba share
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # Enable n8n service
  services.n8n.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8080 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  fileSystems."/mnt/disk/disk1" = {
    device = "/dev/disk/by-uuid/63700bfa-dd4c-4e56-9b01-83d84097b6c7";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/mnt/storage-pool" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/disk/disk1"; # explicit path instead of glob for now, or just add depends
    depends = [ "/mnt/disk/disk1" ];
    options = [
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=epmfs"
      "minfreespace=50G"
      "fsname=mergerfs"
      "allow_other"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/disk/disk1/media 0775 ryan users -"
    "d /mnt/disk/disk1/backups 0775 ryan users -"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  # --- SOPS Configuration ---
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/ryan/.config/sops/age/keys.txt";

  sops.secrets.todoist_api_token = { owner = "ryan"; };
  sops.secrets.todoist_client_secret = { owner = "ryan"; };
  sops.secrets.cloudflare_credentials = { };
  sops.secrets.wg_conf = { };

  # --- Todoist Opencode Bridge Configuration ---
  services.todoist-opencode-bridge = {
    enable = true;
    port = 3000;

    # Path to the decrypted secrets
    todoistApiTokenFile = config.sops.secrets.todoist_api_token.path;
    todoistClientSecretFile = config.sops.secrets.todoist_client_secret.path;

    # Cloudflare configuration
    cloudflaredEnable = true;
    cloudflaredCredentialsFile = config.sops.secrets.cloudflare_credentials.path;
  };

  # Add Jellyfin to the existing cloudflared tunnel
  services.cloudflared.tunnels."todoist-webhook".ingress = {
    "jelly.onayr.com" = "http://localhost:8096";
  };

  # Allow passwordless sudo for nix operations and systemctl
  security.sudo.extraRules = [
    {
      users = [ "ryan" ];
      commands = [
        { command = "/run/current-system/sw/bin/nix"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl"; options = [ "NOPASSWD" ]; }
        { command = "/run/wrappers/bin/mkdir"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/mkdir"; options = [ "NOPASSWD" ]; }
        { command = "/run/wrappers/bin/chown"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/chown"; options = [ "NOPASSWD" ]; }
        { command = "/run/wrappers/bin/chmod"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/chmod"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

}
