{
  description = "Nixos configuration";

  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sfdx.url = "github:rfaulhaber/sfdx-nix";
    sfdx.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    # nixvim.inputs.nixpkgs.follows  = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    todoist-bridge.url = "git+ssh://git@github.com/sonayr/todoist-bridge.git";
    todoist-bridge.inputs.nixpkgs.follows = "nixpkgs";
    nixarr.url = "github:nix-media-server/nixarr";
    nixarr.inputs.nixpkgs.follows = "nixpkgs";
    apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags.url = "github:Aylur/ags";
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, todoist-bridge, nixarr, ... } @ inputs:
    {
      nixosConfigurations = {
        laptop = import ./hosts/laptop/laptop.nix { inherit inputs nixpkgs home-manager; };
        server = import ./hosts/server/server.nix { inherit inputs nixpkgs home-manager; };
        mac = import ./hosts/mac/mac.nix { inherit inputs nixpkgs home-manager; };
      };

      homeConfigurations = {
        "ryan@mac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
          extraSpecialArgs = { inherit inputs; ags = inputs.ags; };
          modules = [ 
	    ./hosts/mac/home.nix 
	    inputs.nixvim.homeModules.nixvim
	    inputs.stylix.homeModules.stylix
	  ];
        };
      };
    };
}
