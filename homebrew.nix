{ ... }:

{
  # Enable Homebrew
  # Note that enabling this option does not install Homebrew, see the Homebrew website for installation instructions.
  # https://brew.sh/
  # https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.enable
  homebrew.enable = true;

  # Automatically use the Brewfile that this module generates in the Nix store
  # https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.global.brewfile
  homebrew.global.brewfile = true;

  homebrew.taps = [
    "homebrew/services"
    "oven-sh/bun"
    "shopify/shopify"
    "sst/tap"
  ];

  # List of Homebrew formulae to install.
  # https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.brews
  homebrew.brews = [
    "awscli"
    "bun"
    "colima"
    "deno"
    "docker-credential-helper-ecr"
    "fabric-ai"
    "gh"
    "mkcert"
    "mysql"
    "pyenv"
    "rbenv"
    "shopify-cli"
    "sst/tap/opencode"
    "uv"
    "volta"
    "yadm"
  ];

  # Prefer installing application from the Mac App Store
  #
  # Commented apps suffer continual update issue:
  # https://github.com/malob/nixpkgs/issues/9
  # homebrew.masApps = {
  #   "1Password for Safari" = 1569813296;
  #   "Pure Paste" = 1611378436;
  #   "Speedtest" = 1153157709;
  #   "Telegram" = 747648890;
  #   "WhatsApp" = 310633997;
  #   "Xcode" = 497799835;
  # };


  # List of Homebrew casks to install.
  # https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.casks
  homebrew.casks = [
    "1password"
    "actual"
    "arc"
    "bruno"
    "chatgpt"
    "claude"
    "daisydisk"
    "discord"
    "docker"
    "gitkraken"
    "google-chrome@canary"
    "gpg-suite-no-mail"
    "ledger-live"
    "logi-options+"
    "karabiner-elements"
    "nordvpn"
    "notion"
    "notion-calendar"
    "obsidian"
    "rectangle"
    "slack"
    "spotify"
    "visual-studio-code"
    "warp"
    "zed"
    "zoom"
  ];
}
