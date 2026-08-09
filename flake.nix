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

  outputs = { self, nixpkgs, darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      nixpkgsLib = pkgs.lib;
      mkDarwinConfiguration = { extraHomeModules ? [ ] }:
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./homebrew.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.zain = {
                imports = [ ./home ] ++ extraHomeModules;
              };
            }
          ];
        };
      syntheticPackage = pkgs.writeShellScriptBin "public-home-check" ''
        echo public-home-check
      '';
      syntheticSource = pkgs.writeText "public-home-source" "public home source\n";
      syntheticHome = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home/public-inputs.nix
          {
            home = {
              username = "synthetic";
              homeDirectory = "/Users/synthetic";
              stateVersion = "24.11";
            };
            nixHome.realization = {
              packages = [ syntheticPackage ];
              files.".config/public-home/source" = syntheticSource;
            };
          }
        ];
      };
      syntheticDarwin = mkDarwinConfiguration {
        extraHomeModules = [
          {
            nixHome.realization = {
              packages = [ syntheticPackage ];
              files.".config/public-home/source" = syntheticSource;
            };
          }
        ];
      };
    in
    {

      # We need a darwinConfigurations output to actually have a `nix-darwin` configuration.
      # https://github.com/LnL7/nix-darwin#flakes-experimental
      darwinConfigurations.zain = mkDarwinConfiguration { };

      lib.mkDarwinConfiguration = mkDarwinConfiguration;

      checks.${system}.public-home-inputs =
        assert nixpkgsLib.elem syntheticPackage syntheticHome.config.home.packages;
        assert syntheticHome.config.home.file.".config/public-home/source".source == syntheticSource;
        assert nixpkgsLib.elem syntheticPackage syntheticDarwin.config.home-manager.users.zain.home.packages;
        assert syntheticDarwin.config.home-manager.users.zain.home.file.".config/public-home/source".source == syntheticSource;
        pkgs.runCommand "public-home-inputs-check" { } ''
          test -x ${syntheticHome.activationPackage}/activate
          test -x ${syntheticPackage}/bin/public-home-check
          test "$(cat ${syntheticSource})" = "public home source"
          touch $out
        '';

      # Set Nix formatter
      # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-fmt#examples
      formatter.${system} = pkgs.nixpkgs-fmt;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
