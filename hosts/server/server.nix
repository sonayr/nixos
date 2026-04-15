{ nixpkgs, inputs, ... }:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    { nix.settings.experimental-features = [ "nix-command" "flakes" ]; }
    inputs.sops-nix.nixosModules.sops
    inputs.todoist-opencode.nixosModules.default
    ./configuration.nix
  ];
}