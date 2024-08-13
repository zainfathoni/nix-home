{ pkgs, ... }:

{
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.shellAliases
  # Shell aliases that is compatible across all shells
  home.shellAliases = {
    # Frequently used Nix scripts
    flakeup = "nix flake update ~/.config/nixpkgs/"; # equivalent to: nix build --recreate-lock-file
    nb = "nix build";
    sw = "./result/sw/bin/darwin-rebuild switch --flake";
    nbsw = "nb .#darwinConfigurations.zain.system && sw .#zain";
    ncg = "nix-collect-garbage -d";
    nfs = "nix flake show";
    npush = ''nix build .#darwinConfigurations.zain.system --json \
      | jq -r '.[].outputs | to_entries[].value' \
      | cachix push zain'';

    # Netlify URL Shorteners
    zainf = "$HOME/Code/GitHub/zainfathoni/shortener/cli.js";
    rbagi = "$HOME/Code/GitHub/zainfathoni/rbagi.id/cli.js";
    imas = "node $HOME/Code/GitHub/zainfathoni/s.imas.sg/node_modules/.bin/netlify-shortener";
    kcovid = "node $HOME/Code/GitLab/kawalcovid19/website/kcov.id/node_modules/.bin/netlify-shortener";
    feid = "node $HOME/Code/GitHub/frontend-id/s.feid.dev/node_modules/.bin/netlify-shortener";
    react = "node $HOME/Code/GitHub/reactjs-id/shortlinks/node_modules/.bin/netlify-shortener";

    # Frequently used Brew commands
    bl = "brew list -1";

    # Frequently used Git commands
    gst = "git status";
    gco = "git checkout";
    gcb = "git checkout -b";
    grb = "git rebase";
    grba = "git rebase --abort";
    grbc = "git rebase --continue";
    grbi = "git rebase -i";
    gpf = "git push --force-with-lease";
    gf = "git fetch";
    gfa = "git fetch --all --prune --jobs=10";
    ggpull = "git pull origin";
    ggpush = "git push origin";
    ggfl = "git push --force-with-lease";

    # Frequently used git-crypt commands
    gcl = "git-crypt lock";
    gcu = "git-crypt unlock";
    gcs = "git-crypt status";
    gcsf = "git-crypt status -f";
  };

  programs = {
    # Z Shell (Default shell)
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable
    zsh.enable = true;

    # Z Shell plugins
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.plugins
    zsh.plugins = [
      {
        name = "zsh-z";
        file = "zsh-z.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "agkozak";
          repo = "zsh-z";
          rev = "afaf2965b41fdc6ca66066e09382726aa0b6aa04";
          sha256 = "1s23azd9hk57dgya0xrqh16jq1qbmm0n70x32mxg8b29ynks6w8n";
        };
      }
    ];


    # Style Z Shell using Starship, a cross-shell prompt
    # https://starship.rs
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.starship.enable
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        command_timeout = 1000;

        ## Warp compatibility
        # https://docs.warp.dev/appearance/prompt#starship-settings
        # Disable the multi-line prompt in Starship
        line_break = {
          disabled = true;
        };

        cmd_duration = {
          format = " [$duration]($style) ";
          style = "bold #EC7279";
          show_notifications = true;
        };
        directory = {
          truncate_to_repo = false;
        };
        nix_shell = {
          format = " [$symbol$state]($style) ";
        };
        battery = {
          full_symbol = "🔋 ";
          charging_symbol = "⚡️ ";
          discharging_symbol = "💀 ";
        };
        git_branch = {
          format = "[$symbol$branch]($style) ";
          symbol = " ";
        };
        gcloud = {
          format = "[$symbol$active]($style) ";
          symbol = "  ";
        };
        aws = {
          symbol = "  ";
        };
        buf = {
          symbol = " ";
        };
        c = {
          symbol = " ";
        };
        conda = {
          symbol = " ";
        };
        dart = {
          symbol = " ";
        };
        directory = {
          read_only = " ";
        };
        docker_context = {
          symbol = " ";
        };
        elixir = {
          symbol = " ";
        };
        elm = {
          symbol = " ";
        };
        golang = {
          symbol = " ";
        };
        haskell = {
          symbol = " ";
        };
        hg_branch = {
          symbol = " ";
        };
        java = {
          symbol = " ";
        };
        julia = {
          symbol = " ";
        };
        memory_usage = {
          symbol = " ";
        };
        nim = {
          symbol = " ";
        };
        nix_shell = {
          symbol = " ";
        };
        nodejs = {
          symbol = " ";
        };
        package = {
          symbol = " ";
          display_private = true;
        };
        python = {
          symbol = " ";
        };
        spack = {
          symbol = "🅢 ";
        };
        rust = {
          symbol = " ";
        };
      };
    };
  };
}



