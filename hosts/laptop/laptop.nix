{ nixpkgs, home-manager, inputs, ... }:


nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    home-manager.nixosModules.home-manager
  ];
}
