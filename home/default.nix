{ pkgs, ... }:

let
  nixHomeSource = pkgs.replaceVars ../scripts/nix-home {
    PYTHON = "${pkgs.python3}/bin/python3";
    NIX_STORE = "${pkgs.nix}/bin/nix-store";
  };
  nixHome = pkgs.runCommand "nix-home" { } ''
    install -Dm755 ${nixHomeSource} $out/bin/nix-home
  '';
in

{
  # https://nix-community.github.io/home-manager/index.html#sec-usage-configuration
  #
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.

  # https://nix-community.github.io/home-manager/options.html#opt-home.stateVersion
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  # https://nix-community.github.io/home-manager/options.html#opt-programs.home-manager.enable
  programs.home-manager.enable = true;

  # Karsa's strict public Darwin realization boundary.
  home.packages = [ nixHome ];
  home.file.".local/bin/nix-home".source = "${nixHome}/bin/nix-home";

  imports = [
    ./public-inputs.nix # Generic final store-safe caller inputs
    ./assets.nix # Symlinked assets configurations
    ./packages.nix # Packages that are not included in `nix-darwin` and `home-manager`
    ./shells.nix # Shell configurations
    ./git.nix # Git configurations
  ];
}
