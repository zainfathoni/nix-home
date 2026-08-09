{ config, lib, ... }:
let
  cfg = config.publicHome;
  isNormalizedRelative = destination:
    destination != ""
    && !(lib.hasPrefix "/" destination)
    && lib.all (component: component != "" && component != "." && component != "..")
      (lib.splitString "/" destination);
  isStoreSource = source: lib.hasPrefix "${builtins.storeDir}/" (toString source);
in
{
  options.publicHome = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Final store-backed packages supplied by the caller.";
    };

    files = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = "Normalized relative home destinations mapped to final store sources.";
    };
  };

  config = {
    assertions = [
      {
        assertion = lib.all isNormalizedRelative (lib.attrNames cfg.files);
        message = "publicHome.files destinations must be normalized relative home paths";
      }
      {
        assertion = lib.all isStoreSource (lib.attrValues cfg.files);
        message = "publicHome.files sources must already be in the Nix store";
      }
    ];

    home.packages = cfg.packages;
    home.file = lib.mapAttrs (_: source: { inherit source; }) cfg.files;
  };
}
