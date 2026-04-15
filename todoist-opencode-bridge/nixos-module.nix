{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.todoist-opencode-bridge;
  
  # A simple derivation to package the node app
  app = pkgs.buildNpmPackage {
    pname = "todoist-opencode-bridge";
    version = "1.0.0";
    src = ./.; # The root of this flake
    npmDepsHash = ""; # Need to generate package-lock.json and hash it, but for a local flake, sometimes easier to just run it via Nix using a prebuilt or setting up the module to run it from source.
    # We will provide an alternative simple runner script approach for the module if package-lock is not yet committed.
  };

in {
  options.services.todoist-opencode-bridge = {
    enable = mkEnableOption "Todoist Opencode Bridge Service";

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Port for the webhook server to listen on.";
    };

    todoistApiTokenFile = mkOption {
      type = types.path;
      description = "Path to the file containing TODOIST_API_TOKEN (e.g. from sops-nix /run/secrets/todoist_api_token).";
    };

    todoistClientSecretFile = mkOption {
      type = types.path;
      description = "Path to the file containing TODOIST_CLIENT_SECRET (e.g. from sops-nix /run/secrets/todoist_client_secret).";
    };

    cloudflaredEnable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically configure a cloudflared tunnel for the webhook server.";
    };

    cloudflaredCredentialsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to the cloudflared credentials.json file (from sops-nix). Required if cloudflaredEnable is true.";
    };
  };

  config = mkIf cfg.enable {
    # Systemd service for the webhook server
    systemd.services.todoist-opencode-bridge = {
      description = "Todoist Opencode Bridge Webhook Server";
      after = [ "network.target" "opencode-headless.service" ];
      wants = [ "opencode-headless.service" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        export TODOIST_API_TOKEN=$(cat ${cfg.todoistApiTokenFile})
        export TODOIST_CLIENT_SECRET=$(cat ${cfg.todoistClientSecretFile})
        export PORT=${toString cfg.port}
        
        # In a real deployment, this would use the built package. 
        # For simplicity in local flake use, we use npx ts-node directly from the flake path if not fully packaged.
        # Ensure we are in the directory with package.json
        cd /home/ryan/todoist-opencode-bridge
        exec ${pkgs.nodejs_20}/bin/npx ts-node src/index.ts
      '';
      
      serviceConfig = {
        User = "ryan";
        Restart = "always";
        RestartSec = "10s";
        # We need the opencode binary available in the PATH
        Environment = "PATH=${lib.makeBinPath [ pkgs.nodejs_20 pkgs.python3 pkgs.gcc pkgs.gnumake ]}:/run/current-system/sw/bin";
      };
    };

    # Cloudflared Tunnel Configuration
    services.cloudflared = mkIf cfg.cloudflaredEnable {
      enable = true;
      tunnels = {
        "todoist-webhook" = {
          credentialsFile = cfg.cloudflaredCredentialsFile;
          default = "http_status:404";
          ingress = {
            "webhooks.onayr.com" = "http://localhost:${toString cfg.port}";
            # Replace webhook.yourdomain.com with your actual tunnel route.
          };
        };
      };
    };

    # Systemd service for the headless opencode server
    systemd.services.opencode-headless = {
      description = "Opencode Headless Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      script = ''
        exec ${pkgs.opencode}/bin/opencode serve --port 4096
      '';

      serviceConfig = {
        User = "ryan";
        WorkingDirectory = "/home/ryan";
        Environment = "PATH=${lib.makeBinPath [ pkgs.nodejs_20 pkgs.python3 pkgs.gcc pkgs.gnumake pkgs.git pkgs.nix ]}:/home/ryan/.nix-profile/bin:/run/current-system/sw/bin";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
