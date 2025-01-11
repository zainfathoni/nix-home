{ config, ... }:
let
  # Make symlink from source out of Nix stores
  inherit (config.lib.file) mkOutOfStoreSymlink;

  # Local nixpkgs working directory
  # FIXME: Find a way to access the home directory without hardcoding it
  # Because we will need it once we want to serve WSL system
  nixConfigDirectory = "/Users/zain/Code/GitHub/zainfathoni/nix-home";
in
{
  # Symlink scripts directory altogether
  home.file."scripts".source = mkOutOfStoreSymlink "${nixConfigDirectory}/assets/scripts";

  # Symlink Warp workflows
  home.file.".warp".source = mkOutOfStoreSymlink "${nixConfigDirectory}/assets/.warp";

  # Symlink Zed configuration files
  home.file.".config/zed/settings.json".source = mkOutOfStoreSymlink "${nixConfigDirectory}/assets/.config/zed/settings.json";
  home.file.".config/zed/keymap.json".source = mkOutOfStoreSymlink "${nixConfigDirectory}/assets/.config/zed/keymap.json";
}
