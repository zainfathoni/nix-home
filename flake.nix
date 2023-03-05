{
  description = "My Home Manager flake";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";

    # Environment/system management
    home-manager.url = "github:nix-community/home-manage";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {
    defaultPackage.aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;

    homeConfigurations = {
      "zainfathoni" = inputs.home-manager.lib.homeManagerConfiguration {
        system = "aarch64-darwin";
        homeDirectory = "/home/zainfathoni";
        username = "zainfathoni";
        configuration.imports = [ ./home.nix ];
      };
    };
  };
}
