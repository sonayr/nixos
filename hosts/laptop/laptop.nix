{ nixpkgs, home-manager, inputs, ... }:


nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ./configuration.nix
    home-manager.nixosModules.home-manager
  ];
}
