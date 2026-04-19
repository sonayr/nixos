{
  description = "Nixos configuration";

  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sfdx.url = "github:rfaulhaber/sfdx-nix";
    sfdx.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    todoist-bridge.url = "git+file:///home/ryan/todoist-opencode-bridge";
    todoist-bridge.inputs.nixpkgs.follows = "nixpkgs";
    nixarr.url = "github:nix-media-server/nixarr";
    nixarr.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, todoist-bridge, nixarr, ... } @ inputs:
    {
      nixosConfigurations = {
        laptop = import ./hosts/laptop/laptop.nix { inherit inputs nixpkgs home-manager; };
        server = import ./hosts/server/server.nix { inherit inputs nixpkgs; };
      };
    };
}
