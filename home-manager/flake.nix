{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-24.11";
    home-manager = {
	url = "github:nix-community/home-manager";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: 
    let
      system = "x86-64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
  {
    homeConfigurations."ry" = home-manager.lib.homeManagerConfiguration {
	inherit pkgs;
	modules = [ ./home.nix ];
    };

  };
}
