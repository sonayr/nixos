{ nixpkgs, inputs, ... }:


nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.apple-silicon.nixosModules.default
    ./configuration.nix
  ];
}
