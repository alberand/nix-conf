{
  pkgs,
  lib,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;

    settings = {
      core = {
        editor = "nvim";
        # Make tabs 8 chars wide
        pager = lib.mkOptionDefault "less -x8 -FX";
        #pager = "delta";
        abbrev = 12;
      };
      diff = {
        algorithm = "patience";
      };
      diff = {
        colorMoved = "default";
      };
      creo = {
        autocrlf = true;
      };
      color = {
        ui = "auto";
      };
      grep = {
        lineNumber = true;
      };
      pull = {
        rebase = true;
      };
      merge = {
        tool = "nvim";
        conflictStyle = lib.mkOptionDefault "diff3";
      };
      mergetool = {
        prompt = false;
        keepBackup = false;
        nvim = {
          cmd = "nvim -d -c \"wincmd l\" -c \"norm ]c\" \"$LOCAL\" \"$MERGED\" \"$REMOTE\" ";
        };
      };
      pretty = {
        fixes = ''Fixes: %h ("%s")'';
      };
      am = {
        threeWay = false;
      };
      rebase = {
        autostash = true;
        autosquash = true;
      };
      format = {
        notes = true;
      };
      oh-my-zsh = {
        hide-info = 1;
      };

      alias = {
        co = "checkout";
        cm = "commit";
        st = "!git lg -n10 ; git status";
        br = "branch";
        wt = "worktree";
        sm = "send-email";
        cp = "cherry-pick";
        # Default output for patches + form cover letter from branch description
        fp = "format-patch -o patches --cover-from-description=subject";
        # Fancy short log
        lg = "log --oneline -n20";
        # Fancy tree log
        hist = ''log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'';
        # Combine b4 and am into one git b4 command
        b4 = "!f() { b4 am -t -o - $1 | git am -3; }; f";
        # Add worktree branch
        wta = "!f() { git worktree add -b $1 ../$1 $2; }; f";
        # Current branch with upstream
        cb = "!git rev-parse --abbrev-ref $(git rev-parse --abbrev-ref HEAD)@{u}";
      };
      advice = {
        setUpstreamFailure = false;
      };
      tag = {
        gpgSign = true;
      };
      sendemail = {
        aliasesFile = "~/.emailaliases";
        aliasFileType = "mutt";
      };
    };

    includes = [
      {
        path = "~/.gitconfig.local";
      }
      {
        path = "~/.gitconfig.redhat.local";
        condition = "gitdir:~/Projects/rhel/**";
      }
    ];

    ignores = [
      "tmp"
      "venv"
      "*.swp"
      "__pycache__"
      "*.pyc"
      ".vscode"

      # Linux
      "tools"
      "Documentation"
      "samples"
      "sound"
      "drivers"
      "arch"
      # This is only due to jj snapshotting, this file is bigger
      # than 1M so it can not be snapshotted by default.
      "crypto/testmgr.h"

      # Nix
      "result"
      ".direnv"

      # My common files
      "todo"
      # vmtest configs
      ".vmtest"
      # xfstests config for vmtest
      "xfstests-config"
      # kernel environment shell
      "kernel-shell.nix"
      # clang cache
      ".cache"
      "*.loT"

      # kd files
      ".kd"
      ".kd.toml"
      ".envrc"
    ];
  };
}
