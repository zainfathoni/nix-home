{ pkgs, lib, ... }:
let
  sshTailnetConfig = pkgs.writeText "sshd-tailnet.conf" ''
    Port 22022
    ListenAddress 127.0.0.1
    PidFile none

    HostKey /etc/ssh/ssh_host_ed25519_key
    HostKey /etc/ssh/ssh_host_ecdsa_key
    HostKey /etc/ssh/ssh_host_rsa_key

    UsePAM yes
    AuthenticationMethods publickey
    PubkeyAuthentication yes
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    PermitEmptyPasswords no
    PermitRootLogin no
    AllowUsers zain
    AuthorizedKeysFile .ssh/authorized_keys
    StrictModes yes

    DisableForwarding yes
    PermitTunnel no
    X11Forwarding no

    AcceptEnv LANG LC_*
    Subsystem sftp /usr/libexec/sftp-server
  '';

  sshTailnetDaemon = pkgs.writeShellScript "ssh-tailnet-daemon" ''
    set -eu

    /usr/bin/ssh-keygen -A
    /usr/sbin/sshd -t -f ${sshTailnetConfig}
    exec /usr/sbin/sshd -D -e -f ${sshTailnetConfig}
  '';

  sshTailnetServeReconciler = pkgs.writeShellScript "ssh-tailnet-serve-reconciler" ''
    set -u

    tailscale=/usr/local/bin/tailscale
    expected_tailnet=zainfathoni.github
    expected_forward=127.0.0.1:22022
    attempt=0

    while [ "$attempt" -lt 60 ]; do
      attempt=$((attempt + 1))

      if [ -x "$tailscale" ]; then
        status_json=$("$tailscale" status --json 2>/dev/null || true)
        backend_state=$(printf '%s' "$status_json" | ${pkgs.jq}/bin/jq -r '.BackendState // empty' 2>/dev/null || true)
        current_tailnet=$(printf '%s' "$status_json" | ${pkgs.jq}/bin/jq -r '.CurrentTailnet.Name // empty' 2>/dev/null || true)

        if [ "$backend_state" = "Running" ] && [ "$current_tailnet" != "$expected_tailnet" ]; then
          exit 0
        fi

        if [ "$backend_state" = "Running" ] && [ "$current_tailnet" = "$expected_tailnet" ]; then
          serve_json=$("$tailscale" serve status --json 2>/dev/null || true)
          current_forward=$(printf '%s' "$serve_json" | ${pkgs.jq}/bin/jq -r '.TCP["22"].TCPForward // empty' 2>/dev/null || true)

          if [ "$current_forward" = "$expected_forward" ]; then
            exit 0
          fi

          if "$tailscale" serve --bg --yes --tcp=22 "tcp://$expected_forward"; then
            serve_json=$("$tailscale" serve status --json 2>/dev/null || true)
            current_forward=$(printf '%s' "$serve_json" | ${pkgs.jq}/bin/jq -r '.TCP["22"].TCPForward // empty' 2>/dev/null || true)
            if [ "$current_forward" = "$expected_forward" ]; then
              exit 0
            fi
          fi
        fi
      fi

      /bin/sleep 5
    done

    exit 1
  '';

  amuxLaunch = pkgs.writeShellScript "amux-launch" ''
    /bin/sleep 15
    exec /Users/zain/.local/bin/amux launch --all
  '';
in
{
  # Make sure the nix daemon always runs
  # Without this configuration, the switch command won't work due to this error:
  # error: The daemon is not enabled but this is a multi-user install, aborting activation
  nix.useDaemon = true;

  # Configure extra options: https://nix-community.github.io/home-manager/options.html#opt-nix.extraOptions
  # `auto-optimise-store` | Storage optimization: https://nixos.wiki/wiki/Storage_optimization
  # `experimental-features` | Enable flakes permanently: https://nixos.wiki/wiki/Flakes#Permanent
  # `extra-nix-path` | Temporary fix for `nix-shell`: https://github.com/DeterminateSystems/nix-installer/pull/270
  # Include Ghostty's own terminfo directory so terminals using
  # `xterm-ghostty` can resolve terminal capabilities in Nix-managed
  # environments (including nix-darwin's generated set-environment script).
  environment.variables.TERMINFO_DIRS = lib.mkForce
    [
      "$HOME/.nix-profile/share/terminfo"
      "/etc/profiles/per-user/$USER/share/terminfo"
      "/run/current-system/sw/share/terminfo"
      "/nix/var/nix/profiles/default/share/terminfo"
      "/usr/share/terminfo"
      "/Applications/Ghostty.app/Contents/Resources/terminfo"
    ];

  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
    extra-nix-path = nixpkgs=flake:nixpkgs
  '';

  # Add trusted substituters
  # I grabbed the public key from https://app.cachix.org/cache/zain#pull
  # Example: https://github.com/LnL7/nix-darwin/blob/0e6857fa1d632637488666c08e7b02c08e3178f8/modules/examples/lnl.nix#L97-L98
  nix.settings.trusted-public-keys = [ "zain.cachix.org-1:BN70psyYfOc8wFoWbRhJo8C40bSejomRRci0BaNhCLE=" ];
  nix.settings.trusted-substituters = [ https://zain.cachix.org ];

  # macOS system defaults configuration
  # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.dock.autohide
  system.defaults.dock.autohide = true;

  # Keyboard mapping
  # https://daiderd.com/nix-darwin/manual/index.html#opt-system.keyboard.enableKeyMapping
  # system.keyboard.enableKeyMapping = true;
  # https://daiderd.com/nix-darwin/manual/index.html#opt-system.keyboard.remapCapsLockToEscape
  # system.keyboard.remapCapsLockToEscape = true;

  # Explicitly set the home directory for the user.
  # https://github.com/nix-community/home-manager/issues/4026#issuecomment-1565487545
  # https://github.com/nix-community/home-manager/issues/4026#issuecomment-1565974702
  # https://daiderd.com/nix-darwin/manual/index.html#opt-users.users._name_.home
  users.users.zain.home = "/Users/zain";

  # Keep Apple's LAN-visible, socket-activated Remote Login service disabled.
  # A dedicated sshd listens only on loopback; Tailscale Serve owns the
  # tailnet-only TCP/22 boundary and preserves unrelated Serve mappings.
  services.openssh.enable = false;

  launchd.daemons.ssh-tailnet = {
    command = sshTailnetDaemon;
    serviceConfig = {
      Label = "dev.zainf.ssh-tailnet";
      KeepAlive = true;
      ProcessType = "Interactive";
      ThrottleInterval = 10;
      ExitTimeOut = 10;
      StandardOutPath = "/var/log/dev.zainf.ssh-tailnet.log";
      StandardErrorPath = "/var/log/dev.zainf.ssh-tailnet.log";
    };
  };

  launchd.user.agents.ssh-tailnet-serve = {
    command = sshTailnetServeReconciler;
    serviceConfig = {
      Label = "dev.zainf.ssh-tailnet-serve";
      RunAtLoad = true;
      StartInterval = 300;
      ProcessType = "Background";
      StandardOutPath = "/Users/zain/Library/Logs/dev.zainf.ssh-tailnet-serve.log";
      StandardErrorPath = "/Users/zain/Library/Logs/dev.zainf.ssh-tailnet-serve.log";
    };
  };

  launchd.user.agents.amux-launch = {
    command = amuxLaunch;
    serviceConfig = {
      Label = "dev.zainf.amux-launch";
      RunAtLoad = true;
      AbandonProcessGroup = true;
      ProcessType = "Background";
      EnvironmentVariables = {
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        PATH = "/Users/zain/.local/bin:/Users/zain/.nix-profile/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
      };
      StandardOutPath = "/Users/zain/Library/Logs/dev.zainf.amux-launch.log";
      StandardErrorPath = "/Users/zain/Library/Logs/dev.zainf.amux-launch.log";
    };
  };

  # nix-darwin system stateVersion
  #@see https://mynixos.com/nix-darwin/option/system.stateVersion
  system.stateVersion = 5;

  # Disable nix-darwin's management of the Nix installation
  # error: Determinate detected, aborting activation
  # Determinate uses its own daemon to manage the Nix installation that
  # conflicts with nix-darwin’s native Nix management.
  # To turn off nix-darwin’s management of the Nix installation, set:
  #     nix.enable = false;
  # This will allow you to use nix-darwin with Determinate. Some nix-darwin
  # functionality that relies on managing the Nix installation, like the
  # `nix.*` options to adjust Nix settings or configure a Linux builder,
  # will be unavailable.
  nix.enable = false;
}
