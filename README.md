# nix-home

A declarative macOS configuration using `nix`, `nix-darwin`, and 'home-manager`.

## Installation

### Build

```shell
nix build .#darwinConfigurations.zain.system
```

### Switch

```shell
./result/sw/bin/darwin-rebuild switch --flake .#zain
```

## References

- [Declarative macOS Configuration Using nix-darwin And home-manager](https://xyno.space/post/nix-darwin-introduction)
