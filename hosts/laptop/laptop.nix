{ nixpkgs, home-manager, inputs, ... }:


nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; ags = inputs.ags; };
  modules = [
    ./configuration.nix
    home-manager.nixosModules.home-manager
  ];
}
