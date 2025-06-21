# AGENTS.md

This file provides guidance for agentic coding agents working with this Nix-based macOS configuration repository.

## Build/Test Commands

- **Build**: `nix build .#darwinConfigurations.zain.system` or `nbsw` (alias)
- **Apply**: `./result/sw/bin/darwin-rebuild switch --flake .#zain` or `nbsw` (alias)
- **Format**: `nix fmt` (formats all .nix files using nixpkgs-fmt)
- **Update**: `nix flake update` or `flakeup` (alias)
- **Validate**: Build command serves as validation - no separate test suite

## Code Style Guidelines

- **Language**: Nix expressions (.nix files)
- **Formatting**: Use `nix fmt` before committing (nixpkgs-fmt formatter)
- **Imports**: Use relative paths (`./file.nix`) for local modules
- **Structure**: Modular configuration with clear separation (system vs home-manager)
- **Comments**: Use `#` for single-line comments, include URLs for documentation references
- **Naming**: Use camelCase for attributes, kebab-case for file names
- **Indentation**: 2 spaces (enforced by nixpkgs-fmt)
- **Strings**: Use double quotes for strings, single quotes for multi-line strings
- **Error Handling**: Nix evaluation errors are caught at build time
- **Types**: Leverage Nix's type system, use `lib.types` for module options