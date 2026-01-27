{ pkgs, ... }:

{
  # Environment variables to always set at login.
  # https://nix-community.github.io/home-manager/options.html#opt-home.sessionVariables
  home.sessionVariables = {
    VOLTA_HOME = "$HOME/.volta";
    PNPM_HOME = "$HOME/.pnpm-global/bin";
    PYENV_ROOT = "$HOME/.pyenv";
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
    # https://github.com/steveyegge/beads/blob/main/docs/GIT_INTEGRATION.md#solutions-for-worktree-users
    BEADS_NO_DAEMON = "1";
    # Default editor
    EDITOR = "vim";
  };

  # Extra directories to add to $PATH
  # https://nix-community.github.io/home-manager/options.html#opt-home.sessionPath
  home.sessionPath = [
    # home-manager per-user profile
    # This is supposed to be set automatically by the home-manager.useUserPackages flag
    # However, it doesn't seem to be working for me
    # Therefore, I'm adding it manually
    # https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-nix-darwin-module
    # FIXME: Remove this once the issue is fixed
    "/etc/profiles/per-user/zain/bin"

    # Amp CLI
    "$HOME/.amp/bin"

    # Volta
    "$VOLTA_HOME/bin"

    # pnpm
    "$HOME/.pnpm-global/bin"
    
    # bun
    "$HOME/.bun/bin"

    # Cloud 66
    "/opt/cloud66/bin"

    # Pyenv
    "$PYENV_ROOT/bin"

    # Bun installation
    "$HOME/.local/bin"

    # Symlinked files in bin directory
    "$HOME/bin"

    # Go binaries
    "$HOME/go/bin"

    # Volta
    "$HOME/.volta/tools/image/node/24.2.0/bin"
  ];

  # The set of packages to appear in the user environment
  # https://nix-community.github.io/home-manager/options.html#opt-home.packages
  home.packages = with pkgs; [
    # Nix Formatter being used by VS Code
    # https://discourse.nixos.org/t/error-with-integration-with-vscode/20848/2
    nixpkgs-fmt

    ##################################
    # Nix-related packages
    ##################################
    cachix # to store cache binaries on cachix.org
    nix-prefetch-git # to get git signatures for fetchFromGit

    ##################################
    # Containerization
    ##################################

    ##################################
    # Languages
    ##################################
    go_1_24
    rustc
    cargo

    ##################################
    # Utilities
    ##################################
    eza # A modern replacement for the `ls` command
    jq # JSON in shell
  ];
}
