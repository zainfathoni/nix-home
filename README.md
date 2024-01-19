# nix-home

This repository is a declarative macOS configuration using `nix`, `nix-darwin`,
and `home-manager`.

- [nix-home](#nix-home)
  - [Installation](#installation)
    - [1. Install Dependencies](#1-install-dependencies)
      - [Install Nix](#install-nix)
      - [Install Homebrew](#install-homebrew)
    - [2. Clone Repository](#2-clone-repository)
    - [3. Build Nix stores](#3-build-nix-stores)
    - [4. Switch to the built Nix stores](#4-switch-to-the-built-nix-stores)
    - [5. Decrypt secrets](#5-decrypt-secrets)
  - [Updates](#updates)
    - [1. Find the latest stable version of Nix](#1-find-the-latest-stable-version-of-nix)
    - [2. Update flake.lock file](#2-update-flakelock-file)
  - [References](#references)

## Installation

### 1. Install Dependencies

#### Install Nix

Install Nix using
[nix-installer](https://zero-to-nix.com/concepts/nix-installer). Read more about
it in the
[Get Nix running on your system](https://zero-to-nix.com/start/install) guide.

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

#### Install Homebrew

We need to [install Homebrew manually](https://brew.sh) because
[`nix-darwin` won't handle Homebrew installation itself](https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.enable).

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Clone Repository

Clone this repository using HTTPS (because, at this point, we can't expect the
new machine to have SSH set up).

```shell
git clone https://github.com/zainfathoni/nix-home.git
```

### 3. Build Nix stores

```shell
nix build .#darwinConfigurations.zain.system
```

### 4. Switch to the built Nix stores

Running the build result would also run the `brew bundle` command, which will
install Brew packages defined in this repository.

```shell
./result/sw/bin/darwin-rebuild switch --flake .#zain
```

### 5. Decrypt secrets

Once `yadm` is installed using the command above, we can use `yadm` to decrypt
the secrets.

```shell
git clone https://github.com/zainfathoni/nix-home.git
yadm decrypt
# enter the passphrase (if prompted)
```

## Updates

Here's how to update the Nix registry to the latest versions.

### 1. Find the latest stable version of Nix

Visit [Nix official website](https://nixos.org/) and find the latest stable
version on the home page. Once you find the latest version, update all versions
in [flake.nix](./flake.nix) and [default.nix](./home/default.nix) files
accordingly.

### 2. Update flake.lock file

If you change nix dependencies, it's better to update the `flake.lock` file
accordingly. You can do it by using either of these commands:

```shell
$ nix build --recreate-lock-file .#darwinConfigurations.zain.system
$ nix flake update ~/.config/nixpkgs/
```

## References

- [Declarative macOS Configuration Using nix-darwin And home-manager](https://xyno.space/post/nix-darwin-introduction)
