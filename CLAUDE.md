# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Repository Overview

This is a declarative macOS configuration using Nix, nix-darwin, and
home-manager. The configuration is flake-based and manages system settings, user
packages, Homebrew packages, and dotfiles through Nix expressions.

## Common Commands

### Build and Switch

```bash
# Build the Nix configuration
nix build .#darwinConfigurations.zain.system

# Switch to the built configuration
./result/sw/bin/darwin-rebuild switch --flake .#zain

# Build and switch in one command (using alias)
nbsw
```

### Updates and Maintenance

```bash
# Update flake inputs
nix flake update

# Collect garbage (remove unused Nix store paths)
nix-collect-garbage -d
# Or use alias: ncg

# Show flake outputs
nix flake show
# Or use alias: nfs

# Push to Cachix (for binary cache)
npush
```

### Formatting

```bash
# Format Nix files
nix fmt
```

## Architecture

### Flake Structure

- `flake.nix`: Main flake definition with inputs (nixpkgs, nix-darwin,
  home-manager)
- `configuration.nix`: System-level nix-darwin configuration
- `homebrew.nix`: Homebrew package management (brews, casks, taps)
- `home/`: Home-manager configuration directory

### Home Manager Modules

- `home/default.nix`: Main home-manager configuration and imports
- `home/packages.nix`: User packages and environment variables
- `home/git.nix`: Git configuration with signing and aliases
- `home/shells.nix`: Shell configuration (zsh, starship, aliases)
- `home/assets.nix`: Symlinked assets and dotfiles

### Key Configuration Patterns

- Uses `mkOutOfStoreSymlink` for assets to avoid copying into Nix store
- Modular configuration with clear separation of concerns
- Extensive shell aliases for common workflows
- GPG signing enabled for Git commits
- Starship prompt with custom symbols and Warp compatibility

## Package Management

### Nix Packages

Managed in `home/packages.nix` - includes development tools, utilities, and
Nix-specific packages.

### Homebrew Packages

Managed in `homebrew.nix`:

- `homebrew.brews`: CLI tools and formulae
- `homebrew.casks`: GUI applications
- `homebrew.taps`: Custom repositories

### System Defaults

macOS system preferences configured in `configuration.nix` using nix-darwin
options.

## Important Aliases

### Nix Operations

- `nbsw`: Build and switch configuration
- `ncg`: Collect garbage
- `npush`: Push to Cachix
- `flakeup`: Update flake inputs

### Git Shortcuts

- `gst`: git status
- `gco`: git checkout
- `gcb`: git checkout -b
- `grb`: git rebase
- `gpf`: git push --force-with-lease

### URL Shorteners

Multiple aliases for personal URL shortener CLIs (zainf, rbagi, imas, etc.)

## Development Workflow

1. Make changes to Nix configuration files
2. Test with `nix build .#darwinConfigurations.zain.system`
3. Apply with `./result/sw/bin/darwin-rebuild switch --flake .#zain`
4. Use `nbsw` alias for build + switch
5. Format code with `nix fmt` before committing

## System Requirements

- macOS (aarch64-darwin architecture)
- Nix with flakes enabled
- Homebrew (must be installed manually)
- GPG keys for Git signing
