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
    todoist-opencode.url = "path:./todoist-opencode-bridge";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, todoist-opencode, ... } @ inputs:
    let
      system = "x86_64-linux";
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
        server = import ./hosts/server/server.nix { inherit inputs nixpkgs; };
      };
    };
}
