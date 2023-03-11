{ pkgs, ... }:
{
  # Make sure the nix daemon always runs
  # Without this configuration, the switch command won't work due to this error:
  # error: The daemon is not enabled but this is a multi-user install, aborting activation
  nix.useDaemon = true;

  # Configure extra options: https://nix-community.github.io/home-manager/options.html#opt-nix.extraOptions
  # Storage optimization: https://nixos.wiki/wiki/Storage_optimization
  # Enable flakes permanently: https://nixos.wiki/wiki/Flakes#Permanent
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '';
}
