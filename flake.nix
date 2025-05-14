{
  description = "Main Computer";

  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sfdx.url = "github:rfaulhaber/sfdx-nix";
    sfdx.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs,home-manager,... } @ inputs: 
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
        myNixos = nixpkgs.lib.nixosSystem {
	   specialArgs = { inherit inputs system; };
	   modules = [
             ./nixos/configuration.nix
	   ];
	};
     };
  };
}
