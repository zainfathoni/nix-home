{
  description = "Pejuang Kode flake";

  inputs = {
    # Package sets
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    # nix will normally use the nixpkgs defined in home-managers inputs, we only want one copy of nixpkgs though
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    # nix will normally use the nixpkgs defined in home-managers inputs, we only want one copy of nixpkgs though
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, darwin, home-manager }: {

    # We need a darwinConfigurations output to actually have a `nix-darwin` configuration.
    # https://github.com/LnL7/nix-darwin#flakes-experimental
    darwinConfigurations.zain = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        # Main `nix-darwin` configuration
        # https://github.com/LnL7/nix-darwin#flakes-experimental
        ./configuration.nix

        # Homebrew configuration
        # https://xyno.space/post/nix-darwin-introduction
        ./homebrew.nix

        # The flake-based setup of the Home Manager `nix-darwin` module
        # https://nix-community.github.io/home-manager/index.html#sec-flakes-nix-darwin-module
        home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.zain = import ./home;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
      ];
    };

    # Set Nix formatter
    # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-fmt#examples
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
  };
}
