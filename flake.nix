{
  description = "Main Computer";

  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-24,11";
  };

  outputs = { self, nixpkgs }: 
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
     nixosConfigurations = {
        myNixos = nixpkgs.lib.nixosSystem {
	   specialArgs = { inherit system; };
	   modules = [
             ./nixos/configuration.nix
	   ];
	};
     };
	
  };
}
