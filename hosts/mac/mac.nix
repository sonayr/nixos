{ nixpkgs, inputs, home-manager, ... }:


nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.apple-silicon.nixosModules.default
    ./configuration.nix
    home-manager.nixosModules.home-manager
  ];
}
