{ config, pkgs, ... }:
let
  # Make symlink from source out of Nix stores
  inherit (config.lib.file) mkOutOfStoreSymlink;

  # Local nixpkgs working directory
  # FIXME: Find a way to access the home directory without hardcoding it
  # Because we will need it once we want to serve WSL system
  nixConfigDirectory = "/Users/zain/Code/GitHub/zainfathoni/nix-home";

  # Pin official runtimes with the eMudhra certificate fixes.
  # https://emudhra.we-have-a-problem.com/
  nodeRuntime = pkgs.fetchzip {
    url = "https://nodejs.org/dist/v26.12.1/node-v26.12.1-darwin-arm64.tar.xz";
    sha256 = "092l0xjjm01prjyb37q10i75dw2x95h7srm5rwpyrb68zq1zivp1";
  };
  bunRuntime = pkgs.fetchzip {
    url = "https://github.com/oven-sh/bun/releases/download/bun-v1.4.4/bun-darwin-aarch64.zip";
    sha256 = "008kcx1n607prm9r01fzl86n4nylcfff3d83hv2mbjpdkh0rxvp3";
  };
in
{
  # Symlink scripts directory altogether
  home.file."scripts".source = mkOutOfStoreSymlink "${nixConfigDirectory}/assets/scripts";

  # Symlink Cloud 66 Toolbelt binary
  # @see https://help.cloud66.com/docs/toolbelt/toolbelt
  # Version cx_0.3.0_darwin_arm64
  home.file."bin/cx".source = mkOutOfStoreSymlink "${nixConfigDirectory}/assets/bin/cx";

  # Symlink Warp workflows
  home.file.".warp".source = mkOutOfStoreSymlink "${nixConfigDirectory}/assets/.warp";

  # Symlink Ghostty terminal configuration
  home.file.".config/ghostty/config".source = mkOutOfStoreSymlink "${nixConfigDirectory}/assets/.config/ghostty/config";

  # Symlink the rex CLI bundled in Rex Beta.app onto PATH
  home.file.".local/bin/rex".source = mkOutOfStoreSymlink "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex";

  # Keep the pinned runtimes ahead of Homebrew and Volta defaults.
  home.file.".local/bin/node".source = "${nodeRuntime}/bin/node";
  home.file.".local/bin/npm".source = "${nodeRuntime}/bin/npm";
  home.file.".local/bin/npx".source = "${nodeRuntime}/bin/npx";
  home.file.".local/bin/bun".source = "${bunRuntime}/bun";
  home.file.".local/bin/bunx".source = "${bunRuntime}/bun";

  # Symlink Zed configuration files
  home.file.".config/zed/settings.json".source = mkOutOfStoreSymlink "${nixConfigDirectory}/assets/.config/zed/settings.json";
  home.file.".config/zed/keymap.json".source = mkOutOfStoreSymlink "${nixConfigDirectory}/assets/.config/zed/keymap.json";

  # Symlink Tycho system prompt templates
  home.file.".tycho/config/system_prompts.yml".source = mkOutOfStoreSymlink "${nixConfigDirectory}/assets/.tycho/config/system_prompts.yml";
}
