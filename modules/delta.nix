{pkgs, ...}: {
  home.packages = [pkgs.delta];

  programs.git = {
    extraConfig = {
      core = {pager = "delta";};
      interactive = {diffFilter = "delta --color-only";};
      delta = {
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        hunk-header-decoration-style = "yellow";
        tabs = "8";
      };
    };
  };
}
