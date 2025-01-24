{
  description = "Plopmenz NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # xnode-manager.url = "github:Openmesh-Network/xnode-manager";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {
        plopmenzPC = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./nixos/configuration.nix
            inputs.sops-nix.nixosModules.sops
            # {
            #   imports = [
            #     inputs.xnode-manager.nixosModules.default
            #   ];
            #   services.xnode-manager.enable = true;
            # }
          ];
        };
      };
    };
}
