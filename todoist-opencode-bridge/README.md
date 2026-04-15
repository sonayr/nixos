# Todoist Opencode Bridge

A webhook server that bridges Todoist tasks to persistent sessions of `opencode`.

## Architecture
- **Todoist Webhooks:** Listens for `item:added`, `item:updated`, and `note:added`.
- **Node-PTY:** Spawns `opencode --agent [plan|build]` in a background pseudo-terminal.
- **Session Manager:** Debounces CLI output, converts it to clean text, and posts to Todoist as a comment. Streams user comments back into the CLI's `stdin`.

## Deployment on NixOS (Flakes + sops-nix + cloudflared)

This flake provides a NixOS module that handles running the Node server as a systemd service and configuring a Cloudflare Tunnel securely using `sops-nix` for secret management.

### 1. Configure Secrets with sops-nix
Create a secrets file in your NixOS configuration (e.g., `secrets.yaml`) and encrypt your tokens using `sops`:

```yaml
todoist_api_token: "your-todoist-token"
todoist_client_secret: "your-todoist-webhook-client-secret"
cloudflare_tunnel_credentials: |
  {"AccountTag":"...","TunnelSecret":"...","TunnelID":"..."}
```

Add them to your NixOS configuration:
```nix
sops.secrets.todoist_api_token = {};
sops.secrets.todoist_client_secret = {};
sops.secrets.cloudflare_tunnel_credentials = {};
```

### 2. Import and Configure the Module
In your system's `configuration.nix` or flake, import the module provided by this flake and enable it:

```nix
{
  inputs.todoist-opencode.url = "path/to/this/flake"; # or github URL
}

# In your NixOS system outputs:
modules = [
  inputs.todoist-opencode.nixosModules.default
  
  ({ config, ... }: {
    services.todoist-opencode-bridge = {
      enable = true;
      port = 3000;
      
      # Paths to the decrypted secrets
      todoistApiTokenFile = config.sops.secrets.todoist_api_token.path;
      todoistClientSecretFile = config.sops.secrets.todoist_client_secret.path;
      
      # Cloudflare Tunnel Config
      cloudflaredEnable = true;
      cloudflaredCredentialsFile = config.sops.secrets.cloudflare_tunnel_credentials.path;
      tunnelId = "your-tunnel-uuid";
    };
    
    # Optional: Update the ingress rule in nixos-module.nix 
    # to match your actual public Cloudflare domain.
  })
];
```

## How to use

1. In Todoist, configure your Webhook URL to point to `https://<your-tunnel-domain>/webhook`.
2. Subscribe to `item:added`, `item:updated`, and `note:added`.
3. Create a task in Todoist. Give it the label `@agent`.
4. (Optional) Give it the label `@Build` to start `opencode` in build mode instead of plan mode.
5. The server will see the new task, generate a `Opencode-Session: <uuid>` in the description, and start the background CLI.
6. Check the task's comments for the output from `opencode`.
7. Reply with a comment to send input back to the agent!
