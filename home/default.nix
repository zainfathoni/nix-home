{ ... }:

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
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  # https://nix-community.github.io/home-manager/options.html#opt-programs.home-manager.enable
  programs.home-manager.enable = true;

  imports = [
    ./packages.nix # Packages that are not included in `nix-darwin` and `home-manager`
    ./shells.nix # Shell configurations
    ./git.nix # Git configurations
  ];
}
