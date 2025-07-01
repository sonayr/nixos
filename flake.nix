{
  description = "Nixos configuration";

  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sfdx.url = "github:rfaulhaber/sfdx-nix";
    sfdx.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      system = "x86-64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      self.submodules = true;
      nixosConfigurations = {
        laptop = import ./hosts/laptop/laptop.nix { inherit inputs nixpkgs home-manager;};
      };
    };
}

