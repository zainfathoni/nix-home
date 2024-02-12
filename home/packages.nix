{ pkgs, ... }:

{
  # Environment variables to always set at login.
  # https://nix-community.github.io/home-manager/options.html#opt-home.sessionVariables
  home.sessionVariables = {
    VOLTA_HOME = "$HOME/.volta";
    PNPM_HOME = "$HOME/.pnpm-global/bin";
  };

  # Extra directories to add to $PATH
  # https://nix-community.github.io/home-manager/options.html#opt-home.sessionPath
  home.sessionPath = [
    # Volta
    "$VOLTA_HOME/bin"

    # pnpm
    "$HOME/.pnpm-global/bin"
  ];

  # The set of packages to appear in the user environment
  # https://nix-community.github.io/home-manager/options.html#opt-home.packages
  home.packages = with pkgs; [
    # Nix Formatter being used by VS Code
    # https://discourse.nixos.org/t/error-with-integration-with-vscode/20848/2
    nixpkgs-fmt
  ];
}
