{ ... }:

let
  zain = {
    name = "Zain Fathoni";
    email = "me@zainf.dev";
    signingKey = "67DDDCE82417961B";
  };
in
{
  programs = {
    git = {
      enable = true;
      userName = zain.name;
      userEmail = zain.email;

      signing = {
        key = zain.signingKey;
        signByDefault = true;
        gpgPath = "gpg";
      };

      ignores = [
        "*~"
        ".DS_Store"
        "*.swp"
      ];

      aliases = {
        st = "status";
        co = "checkout";
        cb = "checkout -b";
        rb = "rebase";
        rba = "rebase --abort";
        rbc = "rebase --continue";
        rbi = "rebase -i";
        pf = "push --force-with-lease";
      };

      diff-so-fancy.enable = true;

      extraConfig = {
        # See https://git-scm.com/book/en/v2/Git-Tools-Rerere
        rerere.enabled = true;
        core.editor = "vim";
      };
    };
  };
}
