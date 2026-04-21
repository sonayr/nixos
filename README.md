# NixOS Configuration

This repository contains my declarative [NixOS](https://nixos.org/) system configuration managed via [Flakes](https://nixos.wiki/wiki/Flakes).

## 🖥️ Hosts

This repository currently defines two main system configurations:

*   **`laptop`**: Personal workstation/laptop configuration. Uses `home-manager` for user-specific environment and dotfiles management.
*   **`server`**: Home server configuration. Runs various self-hosted services and a media server stack.

## ✨ Key Features & Integrations

*   **[Home Manager](https://github.com/nix-community/home-manager)**: Manages user configurations, dotfiles, and user-level packages declaratively.
*   **[sops-nix](https://github.com/Mic92/sops-nix)**: Provides secure, encrypted secrets management using Mozilla SOPS and `age` keys, keeping secrets safe in the public repository.
*   **[nixarr](https://github.com/nix-media-server/nixarr)**: Integrated media server suite for the home server.
*   **Custom Inputs**: Includes tailored environments like `sfdx-nix` and locally sourced applications like `todoist-bridge`.

## 📂 Repository Structure

*   `flake.nix` & `flake.lock`: The core flake entry point, tracking exact versions of all dependencies (inputs).
*   `hosts/`: Machine-specific hardware configurations and system-level setups.
    *   `laptop/`: System definitions for the laptop.
    *   `server/`: Headless system definitions and server-specific roles.
*   `home-manager/`: Contains user-scoped configurations, categorized into `apps`, `dotfiles`, and the central `home.nix`.
*   `services/`: Custom NixOS modules or systemd services shared across hosts.
*   `.sops.yaml`: Defines encryption rules and public `age` keys for managing SOPS secrets securely.

## 🚀 Usage

### Applying System Configuration

To build and apply the configuration for a specific host, navigate to the repository root and run:

```bash
# Apply configuration to the laptop
sudo nixos-rebuild switch --flake .#laptop

# Apply configuration to the server
sudo nixos-rebuild switch --flake .#server
```

*(Note: You can also use `boot` or `test` instead of `switch` depending on whether you want to apply immediately or on the next boot).*

### Updating System Dependencies

To update the system packages and update the `flake.lock` file to the latest commits defined in `flake.nix`:

```bash
nix flake update
```
After updating, rebuild the system using the `nixos-rebuild` command above to apply the changes.

### Secrets Management

Secrets are encrypted using `sops` with `age` encryption. 

To edit a secrets file (e.g., for the server), you must have the corresponding private key on your machine:
```bash
sops hosts/server/secrets.yaml
```

Make sure the private `age` key matches the public key specified in `.sops.yaml` to successfully decrypt and edit.
