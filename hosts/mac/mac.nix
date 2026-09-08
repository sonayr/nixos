{ nixpkgs, inputs, home-manager, ... }:


nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.apple-silicon.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    ./configuration.nix
  ];
}
