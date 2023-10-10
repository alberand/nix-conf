{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;

    extraConfig = {
      core = {
        editor = "nvim";
        # Make tabs 8 chars wide
        pager = "less -x8 -FX";
      };
      diff = {
        algorithm = "patience";
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
    };

    aliases = {
      co = "checkout";
      cm = "commit";
      st = "!git lg -n3 ; git status";
      br = "branch";
      wt = "worktree";
      sm = "send-email";
      # Default output for patches + form cover letter from branch description
      fp = "format-patch -o patches --cover-from-description=subject";
      # Fancy short log
      lg = "log --oneline -n10";
      # Fancy tree log
      hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
      # Skip cover letter emails
      am = "am --empty=keep --allow-empty";
      # Combine b4 and am into one git b4 command
      b4 = "!f() { b4 am -t -o - $1 | git am -3; }; f";
      # Shortcut for backporting in RH (/tmp file is used by hook)
      bp = "!echo $1 > /tmp/.git-backport-$(git rev-parse --abbrev-ref HEAD) && git cherry-pick -x $1";
      # Add worktree branch
      wta = "!f() { git worktree add -b $1 ../$1 $2; }; f";
      # Current branch with upstream
      cb = "!git rev-parse --abbrev-ref $(git rev-parse --abbrev-ref HEAD)@{u}";
    };

    includes = [
      {
        path = "~/.gitconfig.local";
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
      
      # Nix
      "result"
      ".direnv"
      
      # My common files
      "todo"
      # vmtest configs
      ".vmtest"
      # xfstests config for vmtest
      "xfstests-config"
    ];
  };
}
