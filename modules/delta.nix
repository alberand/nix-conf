{pkgs, ...}: {
  home.packages = [pkgs.delta];

  programs.git = {
    settings = {
      core = {pager = "delta";};
      interactive = {diffFilter = "delta --color-only";};
      merge = {
        conflictstyle = "zdiff3";
      };
      delta = {
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        hunk-header-decoration-style = "yellow";
        tabs = "8";
      };
    };
  };
}
