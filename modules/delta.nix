{pkgs, ...}: {
  programs.delta = {
    enable = true;
    enableJujutsuIntegration = true;
    options = {
      decorations = {
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        hunk-header-decoration-style = "yellow";
      };
      tabs = "8";
    };
  };
}
