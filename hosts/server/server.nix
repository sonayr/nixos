{ nixpkgs, inputs, ... }:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.sops-nix.nixosModules.sops
    inputs.todoist-bridge.nixosModules.default
    inputs.nixarr.nixosModules.default
    ./configuration.nix
  ];
}
